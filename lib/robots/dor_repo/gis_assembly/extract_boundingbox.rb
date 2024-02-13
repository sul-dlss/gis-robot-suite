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
            @ulx, @uly, @lrx, @lry = determine_extent
            check_extent

            add_extent_to_geographic_subject
            add_extent_to_projection_form

            object_client.update(params: cocina_object.new(description: description_props))
          ensure
            logger.debug "Cleaning: #{tmpdir}"
            FileUtils.rm_rf tmpdir
          end
        end

        private

        attr_reader :ulx, :uly, :lrx, :lry

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

        def description_props
          @description_props ||= cocina_object.description.to_h
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
          IO.popen("#{Settings.gdal_path}ogrinfo -ro -so -al '#{shape_filename}'") do |ogrinfo_io|
            ogrinfo_io.readlines.each do |line|
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
          IO.popen("#{Settings.gdal_path}gdalinfo -json '#{tiff_filename}'") do |gdalinfo_io|
            ulx = 0
            uly = 0
            lrx = 0
            lry = 0
            # {
            #   "cornerCoordinates":{
            #     "upperLeft":[-32.3338761, 40.5004267], "lowerLeft":[-32.3338761, 36.0005087],
            #     "lowerRight":[-23.8337056, 36.0005087], "upperRight":[-23.8337056, 40.5004267],
            #     "center":[-28.0837908, 38.2504677]
            #   }
            # } # plus many other sibling keys for cornerCoordinates
            gdalinfo_io.read.tap do |gdalinfo_json_str|
              gdalinfo_json = JSON.parse(gdalinfo_json_str)
              corner_coordinates = gdalinfo_json['cornerCoordinates']
              next unless corner_coordinates # everything else depends on a hash nested in the cornerCoordinates field

              ulx, uly = corner_coordinates['upperLeft']
              lrx, lry = corner_coordinates['lowerRight']
            end
            return [ulx, uly, lrx, lry].map { |x| x.to_s.strip.to_f }
          end
        end

        def add_extent_to_geographic_subject
          bounding_box_geographic_subjects.each do |subject|
            subject.clear
            subject[:structuredValue] =
              [
                {
                  value: ulx.to_s,
                  type: 'west'
                },
                {
                  value: lry.to_s,
                  type: 'south'
                },
                {
                  value: lrx.to_s,
                  type: 'east'
                },
                {
                  value: uly.to_s,
                  type: 'north'
                }
              ]
            subject[:type] = 'bounding box coordinates'
            subject[:encoding] = {
              value: 'decimal'
            }
            subject[:standard] = {
              code: 'EPSG:4326'
            }
          end
        end

        def bounding_box_geographic_subjects
          Array(description_props[:geographic]).flat_map do |geo|
            Array(geo[:subject]).select { |subject| subject[:type] == 'bounding box coordinates' }
          end
        end

        def add_extent_to_projection_form
          # Check to see whether the current native projection is WGS84
          raise "extract-boundingbox: #{bare_druid} is missing map projection!" if projection_forms.empty?
          raise "extract-boundingbox: #{bare_druid} has too many map projections: #{projection_forms.size}" unless projection_forms.size == 1

          return update_projection_form_epsg if projection_form_epsg_4326?

          logger.debug "extract-boundingbox: #{bare_druid} has non-native WGS84 projection: #{projection_form[:value]}"

          unless scale_not_given_form?
            description_props[:form] << {
              value: 'Scale not given.',
              type: 'map scale'
            }
          end

          description_props[:form] << {
            value: 'EPSG::4326',
            type: 'map projection',
            uri: 'http://opengis.net/def/crs/EPSG/0/4326',
            source: {
              code: 'EPSG'
            },
            displayLabel: 'WGS84'
          }

          return if wgs84_note?

          description_props[:note] << {
            value: 'This layer is presented in the WGS84 coordinate system for web display purposes. Downloadable data are provided in native coordinate system or projection.',
            displayLabel: 'WGS84 Cartographics'
          }
        end

        def projection_forms
          @projection_forms ||= description_props[:form].select { |form| form[:type] == 'map projection' }
        end

        def projection_form
          @projection_form ||= projection_forms.first
        end

        def projection_form_epsg_4326?
          projection_form[:value] =~ /EPSG:+4326\s*$/
        end

        def scale_not_given_form?
          description_props[:form].any? { |form| form[:value] == 'Scale not given.' && form[:type] == 'map scale' }
        end

        def wgs84_note?
          description_props[:note].any? { |note| note[:displayLabel] == 'WGS84 Cartographics' }
        end

        def update_projection_form_epsg
          logger.debug "extract-boundingbox: #{bare_druid} has native WGS84 projection: #{projection_form[:value]}"
          projection_form[:uri] = 'http://opengis.net/def/crs/EPSG/0/4326'
          projection_form[:source] = {
            code: 'EPSG'
          }
          projection_form[:displayLabel] = 'WGS84'
        end

        # gets the bounding box for the normalize data in tmpdir
        #
        # @return [Array] ulx uly lrx lry for the bounding box
        def determine_extent
          shape_filename = Dir.glob(["#{tmpdir}/*.shp", "#{tmpdir}/*.geojson"]).first
          if shape_filename.nil?
            tiff_filename = Dir.glob("#{tmpdir}/*.tif").first
            ulx, uly, lrx, lry = extent_geotiff tiff_filename # normalized version only
          else
            ulx, uly, lrx, lry = extent_shapefile shape_filename
          end
          logger.debug [ulx, uly, lrx, lry].join(' -- ')
          [ulx, uly, lrx, lry]
        end

        def check_extent
          # Check that we have a valid bounding box
          return if ulx <= lrx && uly >= lry

          raise "extract-boundingbox: #{bare_druid} has invalid bounding box: is not (#{ulx} <= #{lrx} and #{uly} >= #{lry})"
        end
      end
    end
  end
end
