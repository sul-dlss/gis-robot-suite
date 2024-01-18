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

          raise "extract-boundingbox: #{bare_druid} cannot locate normalized data: #{zip_filename}" unless File.size?(zip_filename)

          extract_data_from_zip
          raise "extract-boundingbox: #{bare_druid} cannot locate #{tmpdir}" unless File.directory?(tmpdir)

          begin
            ulx, uly, lrx, lry = determine_extent
            check_extent(ulx, uly, lrx, lry)

            add_geo_extension_to_mods(ulx, uly, lrx, lry)

            description_props = Cocina::Models::Mapping::FromMods::Description.props(mods: mods_doc, druid:,
                                                                                     label: cocina_object.label)
            object_client.update(params: cocina_object.new(description: description_props))
          ensure
            logger.debug "Cleaning: #{tmpdir}"
            FileUtils.rm_rf tmpdir
          end
        end

        private

        def rootdir
          @rootdir ||= GisRobotSuite.locate_druid_path bare_druid, type: :stage
        end

        def zip_filename
          # always use EPSG:4326 derivative
          @zip_filename ||= File.join(rootdir, 'content', 'data_EPSG_4326.zip')
        end

        def tmpdir
          @tmpdir ||= File.join(Settings.geohydra.tmpdir, "extractboundingbox_#{bare_druid}")
        end

        # unpacks a ZIP file into the given tmpdir
        def extract_data_from_zip
          logger.info "extract-boundingbox: #{bare_druid} is extracting data: #{zip_filename}"

          FileUtils.rm_rf(tmpdir) if File.directory? tmpdir
          FileUtils.mkdir_p(tmpdir)
          system("unzip -o '#{zip_filename}' -d '#{tmpdir}'", exception: true)
        end

        # Reads the shapefile to determine extent
        #
        # @return [Array#Float] ulx uly lrx lry
        def extent_shapefile(shape_filename)
          logger.debug "extract-boundingbox: working on Shapefile: #{shape_filename}"
          IO.popen("#{Settings.gdal_path}ogrinfo -ro -so -al '#{shape_filename}'") do |file|
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
        def extent_geotiff(tiff_filename)
          logger.debug "extract-boundingbox: working on GeoTIFF: #{tiff_filename}"
          IO.popen("#{Settings.gdal_path}gdalinfo '#{tiff_filename}'") do |file|
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

        def mods_doc
          @mods_doc ||= Cocina::Models::Mapping::ToMods::Description.transform(cocina_object.description, druid)
        end

        # adds the geo extension to the MODS record
        def add_geo_extension_to_mods(ulx, uly, lrx, lry)
          # Update geo extension
          logger.debug "extract-boundingbox: #{bare_druid} updating geo extension..."
          mods_doc.xpath('/mods:mods/mods:extension[@displayLabel="geo"]/rdf:RDF/rdf:Description/gml:boundedBy/gml:Envelope',
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
          cartos = mods_doc.xpath('/mods:mods/mods:subject/mods:cartographics', 'xmlns:mods' => 'http://www.loc.gov/mods/v3')
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
            subj = Nokogiri::XML::Node.new('subject', mods_doc)
            carto = Nokogiri::XML::Node.new('cartographics', mods_doc)
            scale = Nokogiri::XML::Node.new('scale', mods_doc)
            projection = Nokogiri::XML::Node.new('projection', mods_doc)
            coordinates = Nokogiri::XML::Node.new('coordinates', mods_doc)

            subj['authority'] = 'EPSG'
            subj['valueURI'] = 'http://opengis.net/def/crs/EPSG/0/4326'
            subj['displayLabel'] = 'WGS84'
            scale.content = 'Scale not given.'
            projection.content = 'EPSG::4326'
            coordinates.content = to_coordinates_ddmmss("#{ulx} -- #{lrx}/#{uly} -- #{lry}")

            carto << scale << projection << coordinates
            subj << carto
            mods_doc.root << subj

            # Add note
            note = Nokogiri::XML::Node.new 'note', mods_doc
            note['displayLabel'] = 'WGS84 Cartographics'
            note.content = 'This layer is presented in the WGS84 coordinate system for web display purposes. Downloadable data are provided in native coordinate system or projection.'
            mods_doc.root << note
          end
        end

        # gets the bounding box for the normalize data in tmpdir
        #
        # @return [Array] ulx uly lrx lry for the bounding box
        def determine_extent
          Dir.chdir(tmpdir) do
            shape_filename = Dir.glob('*.shp').first
            if shape_filename.nil?
              tiff_filename = Dir.glob('*.tif').first
              ulx, uly, lrx, lry = extent_geotiff tiff_filename # normalized version only
            else
              ulx, uly, lrx, lry = extent_shapefile shape_filename
            end
            logger.debug [ulx, uly, lrx, lry].join(' -- ')
            return [ulx, uly, lrx, lry]
          end
        end

        def check_extent(ulx, uly, lrx, lry)
          # Check that we have a valid bounding box
          return if ulx <= lrx && uly >= lry

          raise "extract-boundingbox: #{bare_druid} has invalid bounding box: is not (#{ulx} <= #{lrx} and #{uly} >= #{lry})"
        end
      end
    end
  end
end
