# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class ExtractIso19139Metadata < Base
        def initialize
          super('gisAssemblyWF', 'extract-iso19139-metadata')
        end

        def perform_work
          logger.debug "extract-iso19139 working on #{bare_druid}"

          output_file = GisRobotSuite::ArcgisMetadataTransformer.transform(bare_druid, 'ArcGIS2ISO19139.xsl', 'iso19139.xml', logger:)
          object_client.update(params: updated_cocina_with(output_file))
        end

        private

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
