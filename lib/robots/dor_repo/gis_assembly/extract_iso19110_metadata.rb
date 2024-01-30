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

          GisRobotSuite::ArcgisMetadataTransformer.transform(bare_druid, 'ISO19110', logger:)
        end
      end
    end
  end
end
