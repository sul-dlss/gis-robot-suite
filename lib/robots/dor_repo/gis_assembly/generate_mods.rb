# frozen_string_literal: true

require 'scanf'

module Robots
  module DorRepo
    module GisAssembly
      class GenerateMods < Base
        def initialize
          super('gisAssemblyWF', 'generate-mods')
        end

        def perform_work
          logger.debug "generate-mods working on #{bare_druid}"

          description_props = Cocina::Models::Mapping::FromMods::Description.props(mods: mods_ng, druid: cocina_object.externalIdentifier,
                                                                                   label: cocina_object.label)
          object_client.update(params: cocina_object.new(description: description_props))
        end

        private

        def rootdir
          @rootdir ||= GisRobotSuite.locate_druid_path bare_druid, type: :stage
        end

        def geo_metadata_rdf_xml
          # parse cocina geographic as input to MODS transform
          @geo_metadata_rdf_xml ||= Nokogiri::XML(cocina_object.geographic.iso19139)
        end

        def purl
          @purl ||= Settings.purl.url + "/#{bare_druid}"
        end

        def vector_file
          @vector_file ||= Dir.glob(["#{rootdir}/temp/*.shp", "#{rootdir}/temp/*.geojson"]).first
        end

        def vector_file_format
          if vector_file.end_with?('.shp')
            'Shapefile'
          elsif vector_file.end_with?('.geojson')
            'GeoJSON'
          else
            raise "generate-mods: #{bare_druid} cannot detect fileFormat: #{vector_file}"
          end
        end

        def raster?
          vector_file.nil?
        end

        def raster_file_format
          tif_file = Dir.glob("#{rootdir}/temp/*.tif").first
          if tif_file.nil?
            metadata_xml_file = Dir.glob("#{rootdir}/temp/*/metadata.xml").first
            raise "generate-mods: #{bare_druid} cannot detect fileFormat: #{rootdir}/temp" if metadata_xml_file.nil?

            'ArcGRID'
          else
            'GeoTIFF'
          end
        end

        def geometry_type
          @geometry_type ||= if raster?
                               'Raster'
                             elsif geometry_type_ogrinfo =~ /^Line/
                               'LineString'
                             else
                               geometry_type_ogrinfo
                             end
        end

        def file_format
          @file_format ||= if raster?
                             raster_file_format
                           else
                             vector_file_format
                           end
        end

        # Reads the shapefile to determine geometry type
        #
        # @return [String] Point, Polygon, LineString as appropriate
        def geometry_type_ogrinfo
          @geometry_type_ogrinfo ||= find_geometry_type_ogrinfo
        end

        def find_geometry_type_ogrinfo
          IO.popen("#{Settings.gdal_path}ogrinfo -ro -so -al '#{vector_file}'") do |file|
            # When GDAL is upgraded to >= 3.7.0, the -json flag can be added to use JSON output instead of parsing text.
            # json = JSON.parse(file.read)
            # type = json.dig('layers', 0, 'geometryFields', 0, 'type')
            # return type&.gsub('3D', '')&.gsub('Multi', '')&.strip

            file.readlines.each do |line|
              next unless line =~ /^Geometry:\s+(.*)\s*$/

              logger.debug "generate-mods: parsing ogrinfo geometry output: #{line}"
              return Regexp.last_match(1).gsub('3D', '').gsub('Multi', '').strip
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
        def dd2ddmmss_abs(orig_val)
          orig_val_abs_float = orig_val.to_f.abs
          degrees = orig_val_abs_float.floor
          minutes_float = ((orig_val_abs_float - degrees) * 60)
          minutes = minutes_float.floor
          seconds = ((minutes_float - minutes) * 60).round
          if seconds >= 60
            minutes += 1
            seconds = 0
          end
          if minutes >= 60
            degrees += 1
            minutes = 0
          end
          "#{degrees}#{QDEG}" + (minutes > 0 ? "#{minutes}#{QMIN}" : '') + (seconds > 0 ? "#{seconds}#{QSEC}" : '')
        end

        # Convert to MARC 255 DD into DDMMSS
        # westernmost longitude, easternmost longitude, northernmost latitude, and southernmost latitude
        # e.g., -109.758319 -- -88.990844/48.999336 -- 29.423028
        def to_coordinates_ddmmss(orig_val)
          w, e, n, s = orig_val.to_s.scanf('%f -- %f/%f -- %f')
          raise ArgumentError, "Out of bounds latitude: #{n} #{s}" unless n >= -90 && n <= 90 && s >= -90 && s <= 90
          raise ArgumentError, "Out of bounds longitude: #{w} #{e}" unless w >= -180 && w <= 180 && e >= -180 && e <= 180

          w = "#{w < 0 ? 'W' : 'E'} #{dd2ddmmss_abs w}"
          e = "#{e < 0 ? 'W' : 'E'} #{dd2ddmmss_abs e}"
          n = "#{n < 0 ? 'S' : 'N'} #{dd2ddmmss_abs n}"
          s = "#{s < 0 ? 'S' : 'N'} #{dd2ddmmss_abs s}"
          "#{w}--#{e}/#{n}--#{s}"
        end

        MODS_NS = 'http://www.loc.gov/mods/v3'

        # [Nokogiri::XSLT::Stylesheet] for ISO 19139 to MODS
        XSLT_GEOMODS = Nokogiri::XSLT(File.read(File.join(File.dirname(__FILE__), '..', '..', '..', 'xslt', 'iso2mods.xsl')))

        # Generates MODS from ISO 19139
        #
        # @return [Nokogiri::XML::Document] Derived MODS metadata record
        # @raise [RuntimeError] Raises if the generated MODS is empty or has no children
        #
        # Uses GML SimpleFeatures for the geometry type (e.g., Polygon, LineString, etc.)
        # @see http://portal.opengeospatial.org/files/?artifact_id=25355
        #
        def mods_ng
          @mods_ng ||= begin
            doc = XSLT_GEOMODS.transform(geo_metadata_rdf_xml.document, xslt_args)
            raise 'generate-mods: to_mods produced incorrect xml' unless doc.root && !doc.root.children.empty?

            # cleanup projection and coords for human-readable
            doc.xpath('/mods:mods' \
                      '/mods:subject' \
                      '/mods:cartographics' \
                      '/mods:coordinates',
                      'xmlns:mods' => MODS_NS).each do |e|
              e.content = "(#{to_coordinates_ddmmss(e.content.to_s)})"
            end
            doc
          end
        end

        def xslt_args
          params = {
            geometryType: geometry_type || 'Polygon',
            fileFormat: file_format,
            zipName: 'data.zip'
          }
          Nokogiri::XSLT.quote_params(params.transform_keys(&:to_s).to_a.flatten)
        end
      end
    end
  end
end
