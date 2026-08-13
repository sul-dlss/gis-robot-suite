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

          arcgis_transformer.transform
        end

        private

        def arcgis_transformer
          @arcgis_transformer ||= GisRobotSuite::ArcgisMetadataTransformer.new(bare_druid, 'ArcGIS2FGDC.xsl', 'fgdc.xml', logger)
        end
      end
    end
  end
end
