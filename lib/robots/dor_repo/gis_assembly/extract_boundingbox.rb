# frozen_string_literal: true

require 'fileutils'
require 'scanf'

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
          ogrinfo_str = GisRobotSuite.run_system_command("#{Settings.gdal_path}ogrinfo -ro -so -al '#{shape_filename}'", logger:)[:stdout_str]
          # When GDAL is upgraded to >= 3.7.0, the -json flag can be added to use JSON output instead of regexing text line-by-line.
          # json = JSON.parse(ogrinfo_str)
          # extent = json.dig('layers', 0, 'geometryFields', 0, 'extent')
          # return [extent[0].to_f, extent[3].to_f, extent[2].to_f, extent[1].to_f]

          ogrinfo_str.each_line do |line|
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

        # Reads the GeoTIFF to determine box
        #
        # @return [Array#Float] ulx uly lrx lry
        def bounding_box_from_geotiff(tiff_filename)
          logger.debug "extract-boundingbox: working on GeoTIFF: #{tiff_filename}"
          gdalinfo_json_str = GisRobotSuite.run_system_command("#{Settings.gdal_path}gdalinfo -json '#{tiff_filename}'", logger:)[:stdout_str]

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
          gdalinfo_json = JSON.parse(gdalinfo_json_str)
          corner_coordinates = gdalinfo_json['cornerCoordinates']
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
