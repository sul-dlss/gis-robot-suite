# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      # Shared behavior for the robots that transform the ESRI metadata exported from ArcGIS
      # into another metadata standard. Subclasses supply #arcgis_transformer.
      class ExtractMetadataBase < Base
        private

        def missing_metadata_return_state
          LyberCore::ReturnState.new(status: :skipped, note: "#{bare_druid} has no ESRI metadata file in staging")
        end

        # @return [Cocina::Models::DRO] the cocina object with the transform output added to the file set
        #   holding the source ESRI metadata
        def updated_cocina_with(output_file)
          updater = GisRobotSuite::StructuralUpdator.new(cocina_object)
          updater.add_file(filename: output_file, use: 'derivative', file_set:, mimetype: 'application/xml')
        end

        # @return [Cocina::Models::FileSet, nil] the file set containing the source ESRI metadata file
        def file_set
          cocina_object.structural.contains.find do |fs|
            fs.structural.contains.any? { |file| file.filename == arcgis_transformer.esri_metadata_filename }
          end
        end
      end
    end
  end
end
