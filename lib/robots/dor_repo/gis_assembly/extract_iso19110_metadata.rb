# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class ExtractIso19110Metadata < ExtractMetadataBase
        def initialize
          super('gisAssemblyWF', 'extract-iso19110-metadata')
        end

        def perform_work
          logger.debug "extract-iso19110 working on #{bare_druid}"

          return missing_metadata_return_state unless arcgis_transformer.metadata?
          return unless generate_for_datatype?(arcgis_transformer.data_type)

          output_file = arcgis_transformer.transform
          object_client.update(params: updated_cocina_with(output_file))
        end

        private

        def arcgis_transformer
          @arcgis_transformer ||= GisRobotSuite::ArcgisMetadataTransformer.new(bare_druid, 'arcgis_to_iso19110.xsl', 'iso19110.xml', logger)
        end

        def generate_for_datatype?(data_type)
          return false unless %w[Shapefile GeoJSON].include? data_type

          true
        end
      end
    end
  end
end
