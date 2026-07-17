# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class ExtractFgdcMetadata < Base
        def initialize
          super('gisAssemblyWF', 'extract-fgdc-metadata')
        end

        def perform_work
          logger.debug "extract-fgdc working on #{bare_druid}"

          arcgis_transformer = GisRobotSuite::ArcgisMetadataTransformer.new(bare_druid, 'ArcGIS2FGDC.xsl', 'fgdc.xml', logger)
          return missing_metadata_return_state unless arcgis_transformer.metadata?

          arcgis_transformer.transform
        end

        private

        def missing_metadata_return_state
          LyberCore::ReturnState.new(status: :skipped, note: "#{bare_druid} has no ESRI metadata file in staging")
        end
      end
    end
  end
end
