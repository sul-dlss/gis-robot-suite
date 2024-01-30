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

          GisRobotSuite::ArcgisMetadataTransformer.transform(bare_druid, 'FGDC', logger:)
        end
      end
    end
  end
end
