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

        def updated_cocina_with(output_file)
          updater = GisRobotSuite::StructuralUpdator.new(cocina_object)
          updater.add_file(filename: output_file, mimetype: 'application/xml', use: 'derivative')
        end
      end
    end
  end
end
