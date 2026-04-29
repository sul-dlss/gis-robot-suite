# frozen_string_literal: true

module GisRobotSuite
  # This class is responsible for building the list of Cocina Files for the GIS metadata files located in the content directory.
  class MetadataFileBuilder
    # @return [Array<Hash<Symbol, Object>>]
    def self.build(content_dir:, file_access:, version:)
      new(content_dir:, file_access:, version:).build
    end

    def initialize(content_dir:, file_access:, version:)
      @content_dir = content_dir
      @file_access = file_access
      @version = version
    end

    attr_reader :content_dir, :file_access, :version

    def build
      [
        GisRobotSuite::FileParamBuilder.build(objectfile: esri_metadata_objectfile, file_access:, version:, mimetype: 'application/xml')
      ].tap do |params|
        params.concat(metadata_files)
      end
    end

    private

    def esri_metadata_objectfile
      esri_metadata_file = GisRobotSuite.locate_esri_metadata(content_dir)
      @esri_metadata_objectfile ||= Assembly::ObjectFile.new(esri_metadata_file)
    end

    def metadata_files
      GisRobotSuite.locate_derivative_metadata_files(content_dir).map do |file|
        objectfile = Assembly::ObjectFile.new(file)
        GisRobotSuite::FileParamBuilder.build(objectfile:, file_access:, version:, mimetype: 'application/xml', use: 'derivative', preserve: false)
      end
    end
  end
end
