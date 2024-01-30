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

          GisRobotSuite::ArcgisMetadataTransformer.transform(bare_druid, 'ArcGIS2ISO19139.xsl', 'iso19139.xml', logger:)
        end
      end
    end
  end
end
