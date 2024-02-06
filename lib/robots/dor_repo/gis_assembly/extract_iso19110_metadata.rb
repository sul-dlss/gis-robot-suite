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
          arcgis_transformer.transform if generate_for_datatype(arcgis_transformer.data_type)
        end

        private

        def generate_for_datatype(data_type)
          return false unless %w(Shapefile GeoJSON).include? data_type

          true
        end
      end
    end
  end
end
