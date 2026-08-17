# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class ExtractFgdcMetadata < ExtractMetadataBase
        def initialize
          super('gisAssemblyWF', 'extract-fgdc-metadata')
        end

        def perform_work
          logger.debug "extract-fgdc working on #{bare_druid}"

          return missing_metadata_return_state unless arcgis_transformer.metadata?

          output_file = arcgis_transformer.transform
          object_client.update(params: updated_cocina_with(output_file))
        end

        private

        def arcgis_transformer
          @arcgis_transformer ||= GisRobotSuite::ArcgisMetadataTransformer.new(bare_druid, 'ArcGIS2FGDC.xsl', 'fgdc.xml', logger)
        end

        def updated_cocina_with(output_file)
          updater = GisRobotSuite::StructuralUpdator.new(cocina_object)
          updater.add_file(filename: output_file, use: 'derivative', file_set:, mimetype: 'application/xml')
        end

        def file_set
          staging_dir = GisRobotSuite.locate_druid_path(bare_druid, type: :stage)
          esri_metadata_path = GisRobotSuite.locate_esri_metadata(File.join(staging_dir, 'content'))
          esri_metadata_filename = File.basename(esri_metadata_path)

          cocina_object.structural.contains.find do |fs|
            fs.structural.contains.any? { |file| file.filename == esri_metadata_filename }
          end
        end
      end
    end
  end
end
