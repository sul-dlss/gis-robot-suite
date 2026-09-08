# frozen_string_literal: true

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

          @ulx, @uly, @lrx, @lry = bounding_box_calculator.bounding_box # from data files
          check_bounding_box # bounding box is valid

          add_bounding_box_to_geographic_subject

          object_client.update(params: cocina_object.new(description: description_props))
        end

        private

        attr_reader :ulx, :uly, :lrx, :lry

        def bounding_box_calculator
          if GisRobotSuite.vector?(cocina_object)
            GisRobotSuite::VectorBoundingBox.new(cocina_object:, logger:, rootdir:)
          elsif GisRobotSuite.raster?(cocina_object)
            GisRobotSuite::RasterBoundingBox.new(cocina_object:, logger:, rootdir:)
          else
            raise "extract-boundingbox: #{bare_druid} has unknown format: #{GisRobotSuite.media_type(cocina_object)}"
          end
        end

        def rootdir
          @rootdir ||= GisRobotSuite.locate_druid_path bare_druid, type: :stage
        end

        def description_props
          @description_props ||= cocina_object.description.to_h
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

        def check_bounding_box
          # Check that we have a valid bounding box
          return if ulx <= lrx && uly >= lry

          raise "extract-boundingbox: #{bare_druid} has invalid bounding box: is not (#{ulx} <= #{lrx} and #{uly} >= #{lry})"
        end
      end
    end
  end
end
