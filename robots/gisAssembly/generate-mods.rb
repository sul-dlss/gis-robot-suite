# encoding: UTF-8

require 'scanf'

# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisAssembly   # This is your workflow package name (using CamelCase)
      class GenerateMods # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot

        def initialize
          super('dor', 'gisAssemblyWF', 'generate-mods', check_queued_status: true) # init LyberCore::Robot
        end

        # Reads the shapefile to determine geometry type
        #
        # @return [String] Point, Polygon, LineString as appropriate
        def geometry_type_ogrinfo(shp_filename)
          IO.popen("ogrinfo -ro -so -al '#{shp_filename}'") do |f|
            f.readlines.each do |line|
              if line =~ /^Geometry:\s+(.*)\s*$/
                LyberCore::Log.debug "generate-mods: parsing ogrinfo geometry output: #{line}"
                s = Regexp.last_match(1).gsub('3D', '').gsub('Multi', '').strip
                return s
              end
            end
          end
        end

        # Convert DD.DD to DD MM SS.SS
        # e.g.,
        # * -109.758319 => 109°45ʹ29.9484ʺ
        # * 48.999336 => 48°59ʹ57.609ʺ
        E = 1
        QSEC = 'ʺ'
        QMIN = 'ʹ'
        QDEG = "\u00B0"
        def dd2ddmmss_abs(f)
          dd = f.to_f.abs
          d = dd.floor
          mm = ((dd - d) * 60)
          m = mm.floor
          s = ((mm - mm.floor) * 60).round
          if s >= 60
            m += 1
            s = 0
          end
          if m >= 60
            d += 1
            m = 0
          end
          "#{d}#{QDEG}" + (m > 0 ? "#{m}#{QMIN}" : '') + (s > 0 ? "#{s}#{QSEC}" : '')
        end

        # Convert to MARC 255 DD into DDMMSS
        # westernmost longitude, easternmost longitude, northernmost latitude, and southernmost latitude
        # e.g., -109.758319 -- -88.990844/48.999336 -- 29.423028
        def to_coordinates_ddmmss(s)
          w, e, n, s = s.to_s.scanf('%f -- %f/%f -- %f')
          fail ArgumentError, "Out of bounds latitude: #{n} #{s}" unless n >= -90 && n <= 90 && s >= -90 && s <= 90
          fail ArgumentError, "Out of bounds longitude: #{w} #{e}" unless w >= -180 && w <= 180 && e >= -180 && e <= 180
          w = "#{w < 0 ? 'W' : 'E'} #{dd2ddmmss_abs w}"
          e = "#{e < 0 ? 'W' : 'E'} #{dd2ddmmss_abs e}"
          n = "#{n < 0 ? 'S' : 'N'} #{dd2ddmmss_abs n}"
          s = "#{s < 0 ? 'S' : 'N'} #{dd2ddmmss_abs s}"
          "#{w}--#{e}/#{n}--#{s}"
        end

        MODS_NS = 'http://www.loc.gov/mods/v3'

        # [Nokogiri::XSLT::Stylesheet] for ISO 19139 to MODS
        XSLT_GEOMODS = Nokogiri::XSLT(File.read(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'xslt', 'iso2mods.xsl')))

        # Generates MODS from ISO 19139
        #
        # @return [Nokogiri::XML::Document] Derived MODS metadata record
        # @raise [RuntimeError] Raises if the generated MODS is empty or has no children
        #
        # Uses GML SimpleFeatures for the geometry type (e.g., Polygon, LineString, etc.)
        # @see http://portal.opengeospatial.org/files/?artifact_id=25355
        #
        def to_mods(metadata, params)
          params[:geometryType] ||= 'Polygon'
          params[:zipName] ||= 'data.zip'
          fail ArgumentError, 'generate-mods: Missing PURL parameter' if params[:purl].nil?

          args = Nokogiri::XSLT.quote_params(Hash[params.map { |(k, v)| [k.to_s, v] }].to_a.flatten)
          doc = XSLT_GEOMODS.transform(metadata.document, args)
          unless doc.root && doc.root.children.size > 0
            fail 'generate-mods: to_mods produced incorrect xml'
          end

          # cleanup projection and coords for human-readable
          doc.xpath('/mods:mods' \
            '/mods:subject' \
            '/mods:cartographics' \
            '/mods:coordinates',
                    'xmlns:mods' => MODS_NS).each do |e|
            e.content = '(' + to_coordinates_ddmmss(e.content.to_s) + ')'
          end
          doc
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid = GisRobotSuite.initialize_robot druid
          LyberCore::Log.debug "generate-mods working on #{druid}"

          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage

          # short-circuit if already have MODS file
          fn = File.join(rootdir, 'metadata', 'descMetadata.xml')
          if File.size?(fn)
            LyberCore::Log.info "generate-mods: #{druid} found existing #{fn}"
            return
          end

          fn = File.join(rootdir, 'metadata', 'geoMetadata.xml')
          fail "generate-mods: #{druid} cannot locate #{fn}" unless File.size?(fn)

          # parse geometadata as input to MODS transform
          geoMetadataDS = Nokogiri::XML(File.read(fn))

          # detect fileFormat and geometryType
          fn = Dir.glob("#{rootdir}/temp/*.shp").first
          unless fn.nil?
            geometryType = geometry_type_ogrinfo(fn)
            geometryType = 'LineString' if geometryType =~ /^Line/
            fileFormat = 'Shapefile'
          else
            geometryType = 'Raster'
            fn = Dir.glob("#{rootdir}/temp/*.tif").first
            unless fn.nil?
              fileFormat = 'GeoTIFF'
            else
              fn = Dir.glob("#{rootdir}/temp/*/metadata.xml").first
              unless fn.nil?
                fileFormat = 'ArcGRID'
              else
                fail "generate-mods: #{druid} cannot detect fileFormat: #{rootdir}/temp"
              end
            end
          end

          # load PURL
          purl = Settings.purl.url + "/#{druid.gsub(/^druid:/, '')}"

          # XXX: clean up dor-services geoMetadataDS to not generate transforms
          modsFn = File.join(rootdir, 'metadata', 'descMetadata.xml')
          File.open(modsFn, 'wb') do |f|
            begin
              f << to_mods(geoMetadataDS, geometryType: geometryType,
                                          fileFormat: fileFormat,
                                          purl: purl).to_xml(index: 2)
            rescue ArgumentError => e
              raise "generate-mods: #{druid} cannot process MODS: #{e}"
            end
          end
          fail "generate-mods: #{druid} did not write MODS correctly" unless File.size?(modsFn)
        end
      end
    end
  end
end
