# frozen_string_literal: true

require 'fileutils'

module Robots
  module DorRepo
    module GisAssembly
      # Updates cocina description with bounding box information extracted from the data files.
      class ExtractBoundingbox < Base
        def initialize
          super('gisAssemblyWF', 'extract-boundingbox')
        end

        def perform_work
          logger.debug "extract-boundingbox working on #{bare_druid}"

          normalizer.with_normalized do |tmpdir|
            @tmpdir = tmpdir
            @ulx, @uly, @lrx, @lry = determine_bounding_box # from data files
            check_bounding_box # bounding box is valid

            add_bounding_box_to_geographic_subject

            object_client.update(params: cocina_object.new(description: description_props))
          end
        end

        private

        attr_reader :ulx, :uly, :lrx, :lry, :tmpdir

        def normalizer
          if GisRobotSuite.vector?(cocina_object)
            GisRobotSuite::VectorNormalizer.new(bare_druid:, logger:, rootdir:)
          else
            GisRobotSuite::RasterNormalizer.new(cocina_object:, logger:, rootdir:)
          end
        end

        def rootdir
          @rootdir ||= GisRobotSuite.locate_druid_path bare_druid, type: :stage
        end

        def description_props
          @description_props ||= cocina_object.description.to_h
        end

        # Reads the shapefile to determine bounding box
        #
        # @return [Array#Float] ulx uly lrx lry
        def bounding_box_from_shapefile(shape_filename)
          logger.debug "extract-boundingbox: working on Shapefile: #{shape_filename}"
          vector_info_json_str = GisRobotSuite.run_system_command("#{Settings.gdal_path}gdal vector info -f json '#{shape_filename}'", logger:)[:stdout_str]

          vector_info_json = JSON.parse(vector_info_json_str)
          extent = vector_info_json.dig('layers', 0, 'geometryFields', 0, 'extent')
          # extent is [min_x, min_y, max_x, max_y] --> [west, south, east, north]
          [extent[0].to_f, extent[3].to_f, extent[2].to_f, extent[1].to_f]
        end

        # Reads the GeoTIFF to determine box
        #
        # @return [Array#Float] ulx uly lrx lry
        def bounding_box_from_geotiff(tiff_filename)
          logger.debug "extract-boundingbox: working on GeoTIFF: #{tiff_filename}"
          raster_info_json_str = GisRobotSuite.run_system_command("#{Settings.gdal_path}gdal raster info -f json '#{tiff_filename}'", logger:)[:stdout_str]

          ulx = 0
          uly = 0
          lrx = 0
          lry = 0
          # {
          #   "cornerCoordinates":{
          #     "upperLeft":[16.1179474, 70.6126121],
          #     "lowerLeft":[16.1179474, 59.2022116],
          #     "lowerRight":[32.2367687, 59.2022116],
          #     "upperRight":[32.2367687, 70.6126121],
          #     "center":[24.1773581, 64.9074119]
          #   }
          # }
          raster_info_json = JSON.parse(raster_info_json_str)
          corner_coordinates = raster_info_json['cornerCoordinates']
          unless corner_coordinates.blank?
            ulx, uly = corner_coordinates['upperLeft']
            lrx, lry = corner_coordinates['lowerRight']
          end

          [ulx, uly, lrx, lry].map { |x| x.to_s.strip.to_f }
        end

        def add_bounding_box_to_geographic_subject
          # add new bounding box subject or replace existing boundng box subject
          delete_bounding_box_geographic_subjects

          geographic = description_props[:geographic]
          geographic.first[:subject] << bounding_box_geographic_subject
        end

        def delete_bounding_box_geographic_subjects
          # delete existing bounding box coordinates so that they can be replaced with re-generated coordinates
          Array(description_props[:geographic]).flat_map do |geo|
            Array(geo[:subject]).reject! { |subject| subject[:type] == 'bounding box coordinates' }
          end
        end

        def bounding_box_geographic_subject
          { structuredValue:
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
            ],
            type: 'bounding box coordinates',
            encoding: {
              value: 'decimal'
            },
            standard: { code: 'EPSG:4326' } }
        end

        # gets the bounding box for the normalize data in tmpdir
        #
        # @return [Array] ulx uly lrx lry for the bounding box
        def determine_bounding_box
          shape_filename = Dir.glob(["#{tmpdir}/*.shp", "#{tmpdir}/*.geojson"]).first
          if shape_filename.nil?
            tiff_filename = Dir.glob("#{tmpdir}/*.tif").first
            ulx, uly, lrx, lry = bounding_box_from_geotiff tiff_filename # normalized version only
          else
            ulx, uly, lrx, lry = bounding_box_from_shapefile shape_filename
          end
          logger.debug [ulx, uly, lrx, lry].join(' -- ')
          [ulx, uly, lrx, lry]
        end

        def check_bounding_box
          # Check that we have a valid bounding box
          return if ulx <= lrx && uly >= lry

          raise "extract-boundingbox: #{bare_druid} has invalid bounding box: is not (#{ulx} <= #{lrx} and #{uly} >= #{lry})"
        end
      end
    end
  end
end
