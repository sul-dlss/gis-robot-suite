# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class ExtractIso19139Metadata < ExtractMetadataBase
        def initialize
          super('gisAssemblyWF', 'extract-iso19139-metadata')
        end

        def perform_work
          logger.debug "extract-iso19139 working on #{bare_druid}"

          return missing_metadata_return_state unless arcgis_transformer.metadata?

          output_file = arcgis_transformer.transform
          GisRobotSuite::Iso19139BandUnits.apply(output_file, esri_ng:, logger:)
          GisRobotSuite::Iso19139BoundingBox.apply(output_file, bounding_box:, logger:)
          object_client.update(params: updated_cocina_with(output_file))
        end

        private

        def arcgis_transformer
          @arcgis_transformer ||= GisRobotSuite::ArcgisMetadataTransformer.new(bare_druid, 'ArcGIS2ISO19139.xsl', 'iso19139.xml', logger)
        end

        # The stylesheet drops the vertical coordinate system, so the band units have to be
        # patched in afterwards from the ESRI metadata the transform read. The ESRI metadata also
        # names the projection the bounding box falls back on when the data declares none.
        def esri_ng
          @esri_ng ||= Nokogiri::XML(File.read(arcgis_transformer.esri_metadata_file))
        end

        def bounding_box
          GisRobotSuite::BoundingBox.from_data(rootdir: staging_dir, esri_ng:, logger:, bare_druid:)
        end

        def staging_dir
          GisRobotSuite::StagedContent.find!(bare_druid).pathname.to_s
        end
      end
    end
  end
end
