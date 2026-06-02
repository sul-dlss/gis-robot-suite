# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class ExtractIso19110Metadata < Base
        def initialize
          super('gisAssemblyWF', 'extract-iso19110-metadata')
        end

        def perform_work
          logger.debug "extract-iso19110 working on #{bare_druid}"

          arcgis_transformer = GisRobotSuite::ArcgisMetadataTransformer.new(bare_druid, 'arcgis_to_iso19110.xsl', 'iso19110.xml', logger)
          return unless generate_for_datatype?(arcgis_transformer.data_type)

          output_file = arcgis_transformer.transform
          object_client.update(params: updated_cocina_with(output_file))
        end

        private

        def updated_cocina_with(output_file)
          updater = GisRobotSuite::StructuralUpdator.new(cocina_object)
          updater.add_file(filename: output_file, mimetype: 'application/xml', use: 'derivative', file_set:)
        end

        def file_set
          staging_dir = GisRobotSuite.locate_druid_path(bare_druid, type: :stage)
          esri_metadata_path = GisRobotSuite.locate_esri_metadata(File.join(staging_dir, 'content'))
          esri_metadata_filename = File.basename(esri_metadata_path)

          cocina_object.structural.contains.find do |fs|
            fs.structural.contains.any? { |file| file.filename == esri_metadata_filename }
          end
        end

        def generate_for_datatype?(data_type)
          return false unless %w[Shapefile GeoJSON].include? data_type

          true
        end
      end
    end
  end
end
