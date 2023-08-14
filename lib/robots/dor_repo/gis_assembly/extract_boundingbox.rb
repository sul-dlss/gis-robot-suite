# frozen_string_literal: true

require 'fileutils'
require 'scanf'

module Robots
  module DorRepo
    module GisAssembly
      class ExtractBoundingbox < Base
        def initialize
          super('gisAssemblyWF', 'extract-boundingbox')
        end

        def perform_work
          logger.debug "extract-boundingbox working on #{bare_druid}"

          rootdir = GisRobotSuite.locate_druid_path bare_druid, type: :stage

          mods_filename = File.join(rootdir, 'metadata', 'descMetadata.xml')
          raise "extract-boundingbox: #{bare_druid} cannot locate MODS: #{mods_filename}" unless File.size?(mods_filename)

          projection = '4326' # always use EPSG:4326 derivative
          zipfn = File.join(rootdir, 'content', "data_EPSG_#{projection}.zip")
          raise "extract-boundingbox: #{bare_druid} cannot locate normalized data: #{zipfn}" unless File.size?(zipfn)

          tmpdir = extract_data_from_zip(zipfn, Settings.geohydra.tmpdir)
          raise "extract-boundingbox: #{bare_druid} cannot locate #{tmpdir}" unless File.directory?(tmpdir)

          begin
            ulx, uly, lrx, lry = determine_extent(tmpdir)

            # Check that we have a valid bounding box
            # rubocop:disable Style/IfUnlessModifier
            # due to line length
            unless ulx <= lrx && uly >= lry
              raise "extract-boundingbox: #{bare_druid} has invalid bounding box: is not (#{ulx} <= #{lrx} and #{uly} >= #{lry})"
            end
            # rubocop:enable Style/IfUnlessModifier

            add_geo_extension_to_mods(mods_filename, ulx, uly, lrx, lry)
            raise "extract-boundingbox: #{bare_druid} corrupted MODS: #{mods_filename}" unless File.size?(mods_filename)
          ensure
            logger.debug "Cleaning: #{tmpdir}"
            FileUtils.rm_rf tmpdir
          end
        end

        private

        # unpacks a ZIP file into the given tmpdir
        # @return [String] tmpdir the folder in which to extract files
        def extract_data_from_zip(zipfn, tmpdir)
          logger.info "extract-boundingbox: #{bare_druid} is extracting data: #{zipfn}"

          tmpdir = File.join(tmpdir, "extractboundingbox_#{bare_druid}")
          FileUtils.rm_rf(tmpdir) if File.directory? tmpdir
          FileUtils.mkdir_p(tmpdir)
          system("unzip -o '#{zipfn}' -d '#{tmpdir}'", exception: true)
          tmpdir
        end

        # Reads the shapefile to determine extent
        #
        # @return [Array#Float] ulx uly lrx lry
        def extent_shapefile(shpfn)
          logger.debug "extract-boundingbox: working on Shapefile: #{shpfn}"
          IO.popen("#{Settings.gdal_path}ogrinfo -ro -so -al '#{shpfn}'") do |file|
            file.readlines.each do |line|
              # Extent: (-151.479444, 26.071745) - (-78.085007, 69.432500) --> (W, S) - (E, N)
              next unless line =~ /^Extent:\s+\((.*),\s*(.*)\)\s+-\s+\((.*),\s*(.*)\)/

              w, s, e, n = [Regexp.last_match(1), Regexp.last_match(2), Regexp.last_match(3), Regexp.last_match(4)].map(&:to_s)
              ulx = w
              uly = n
              lrx = e
              lry = s
              return [ulx, uly, lrx, lry].map { |x| x.to_s.strip.to_f }
            end
          end
        end

        # Reads the GeoTIFF to determine extent
        #
        # @return [Array#Float] ulx uly lrx lry
        def extent_geotiff(tiffn)
          logger.debug "extract-boundingbox: working on GeoTIFF: #{tiffn}"
          IO.popen("#{Settings.gdal_path}gdalinfo '#{tiffn}'") do |file|
            ulx = 0
            uly = 0
            lrx = 0
            lry = 0
            file.readlines.each do |line|
              # Corner Coordinates:
              # Upper Left  (-122.2846400,  35.9770286) (122d17' 4.70"W, 35d58'37.30"N)
              # Lower Left  (-122.2846400,  35.5581835) (122d17' 4.70"W, 35d33'29.46"N)
              # Upper Right (-121.9094764,  35.9770286) (121d54'34.12"W, 35d58'37.30"N)
              # Lower Right (-121.9094764,  35.5581835) (121d54'34.12"W, 35d33'29.46"N)
              # Center      (-122.0970582,  35.7676061) (122d 5'49.41"W, 35d46' 3.38"N)
              case line
              when /^Upper Left\s+\((.*)\)\s+\(/
                ulx, uly = Regexp.last_match(1).split(',')
              when /^Lower Right\s+\((.*)\)\s+\(/
                lrx, lry = Regexp.last_match(1).split(',')
              end
            end
            return [ulx, uly, lrx, lry].map { |x| x.to_s.strip.to_f }
          end
        end

        # Convert DD.DD to DD MM SS
        # e.g.,
        # * -109.758319 => 109°45ʹ30ʺ
        # * 48.999336 => 48°59ʹ58ʺ
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
          raise ArgumentError, "generate-mods: Out of bounds latitude: #{n} #{s}" unless n >= -90 && n <= 90 && s >= -90 && s <= 90
          raise ArgumentError, "generate-mods: Out of bounds longitude: #{w} #{e}" unless w >= -180 && w <= 180 && e >= -180 && e <= 180

          w = "#{w < 0 ? 'W' : 'E'} #{dd2ddmmss_abs w}"
          e = "#{e < 0 ? 'W' : 'E'} #{dd2ddmmss_abs e}"
          n = "#{n < 0 ? 'S' : 'N'} #{dd2ddmmss_abs n}"
          s = "#{s < 0 ? 'S' : 'N'} #{dd2ddmmss_abs s}"
          "#{w}--#{e}/#{n}--#{s}"
        end

        # adds the geo extension to the MODS record
        def add_geo_extension_to_mods(mods_filename, ulx, uly, lrx, lry)
          logger.debug "extract-boundingbox: #{bare_druid} reading #{mods_filename}"
          doc = Nokogiri::XML(File.binread(mods_filename))

          # Update geo extension
          logger.debug "extract-boundingbox: #{bare_druid} updating geo extension..."
          doc.xpath('/mods:mods/mods:extension[@displayLabel="geo"]/rdf:RDF/rdf:Description/gml:boundedBy/gml:Envelope',
                    'xmlns:mods' => 'http://www.loc.gov/mods/v3',
                    'xmlns:rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
                    'xmlns:gml' => 'http://www.opengis.net/gml/3.2/').each do |node|
            node['gml:srsName'] = 'EPSG:4326'
            node.xpath('gml:upperCorner', 'xmlns:gml' => 'http://www.opengis.net/gml/3.2/').each do |x|
              logger.debug "extract-boundingbox: #{bare_druid} replacing upperCorner #{x.content} with #{lrx} #{uly}"
              x.content = [lrx, uly].join(' ') # NE
            end
            node.xpath('gml:lowerCorner', 'xmlns:gml' => 'http://www.opengis.net/gml/3.2/').each do |x|
              logger.debug "extract-boundingbox: #{bare_druid} replacing lowerCorner #{x.content} with #{ulx} #{lry}"
              x.content = [ulx, lry].join(' ') # SW
            end
          end

          # Check to see whether the current native projection is WGS84
          cartos = doc.xpath('/mods:mods/mods:subject/mods:cartographics', 'xmlns:mods' => 'http://www.loc.gov/mods/v3')
          raise "extract-boundingbox: #{bare_druid} is missing subject/cartographics!" if cartos.nil?

          logger.debug "extract-boundingbox: #{bare_druid} has #{cartos.size} subject/cartographics elements"
          raise "extract-boundingbox: #{bare_druid} has too many subject/cartographics elements: #{cartos.size}" unless cartos.size == 1

          carto = cartos.first
          proj = carto.xpath('mods:projection', 'xmlns:mods' => 'http://www.loc.gov/mods/v3').first

          if proj.content =~ /EPSG:+4326\s*$/
            logger.debug "extract-boundingbox: #{bare_druid} has native WGS84 projection: #{proj.content}"
            subj = carto.parent
            subj['authority'] = 'EPSG'
            subj['valueURI'] = 'http://opengis.net/def/crs/EPSG/0/4326'
            subj['displayLabel'] = 'WGS84'
          else
            logger.debug "extract-boundingbox: #{bare_druid} has non-native WGS84 projection: #{proj.content}"

            # Add subject/cartographics for WGS84 projection
            subj = Nokogiri::XML::Node.new('subject', doc)
            carto = Nokogiri::XML::Node.new('cartographics', doc)
            scale = Nokogiri::XML::Node.new('scale', doc)
            projection = Nokogiri::XML::Node.new('projection', doc)
            coordinates = Nokogiri::XML::Node.new('coordinates', doc)

            subj['authority'] = 'EPSG'
            subj['valueURI'] = 'http://opengis.net/def/crs/EPSG/0/4326'
            subj['displayLabel'] = 'WGS84'
            scale.content = 'Scale not given.'
            projection.content = 'EPSG::4326'
            coordinates.content = to_coordinates_ddmmss("#{ulx} -- #{lrx}/#{uly} -- #{lry}")

            carto << scale << projection << coordinates
            subj << carto
            doc.root << subj

            # Add note
            note = Nokogiri::XML::Node.new 'note', doc
            note['displayLabel'] = 'WGS84 Cartographics'
            note.content = 'This layer is presented in the WGS84 coordinate system for web display purposes. Downloadable data are provided in native coordinate system or projection.'
            doc.root << note
          end

          # Save
          logger.debug "extract-boundingbox: #{bare_druid} saving updated MODS to #{mods_filename}"
          File.open(mods_filename, 'wb') do |line|
            doc.write_xml_to(line, indent: 2, encoding: 'UTF-8')
          end
        end

        # gets the bounding box for the normalize data in tmpdir
        #
        # @param [String] datadir directory that holds data files
        # @return [Array] ulx uly lrx lry for the bounding box
        def determine_extent(datadir)
          Dir.chdir(datadir) do
            shpfn = Dir.glob('*.shp').first
            if shpfn.nil?
              tiffn = Dir.glob('*.tif').first
              ulx, uly, lrx, lry = extent_geotiff tiffn # normalized version only
            else
              ulx, uly, lrx, lry = extent_shapefile shpfn
            end
            logger.debug [ulx, uly, lrx, lry].join(' -- ')
            return [ulx, uly, lrx, lry]
          end
        end
      end
    end
  end
end
