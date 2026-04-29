# frozen_string_literal: true

module GisRobotSuite
  class DataFileBuilder
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
      data_files.map do |file|
        file = to_geojson(file) if File.extname(file) == '.json'
        objectfile = Assembly::ObjectFile.new(file)
        FileParamBuilder.build(objectfile:, file_access:, version:, mimetype: mimetype_for_file(objectfile))
      end
    end

    private

    def to_geojson(file)
      new_file = File.join(content_dir, "#{File.basename(file, '.json')}.geojson")
      File.rename(file, new_file)
      new_file
    end

    def mimetype_for_file(objectfile)
      DataFileFinder::FILE_MIMETYPES.each do |ext, mimetype|
        return mimetype if objectfile.filename.end_with?(ext)
      end

      'application/octet-stream'
    end

    def data_files
      DataFileFinder.find(content_dir:)
    end
  end
end
