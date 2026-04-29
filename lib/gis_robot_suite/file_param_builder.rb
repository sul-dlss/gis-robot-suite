# frozen_string_literal: true

module GisRobotSuite
  # This class is responsible for building the Cocina File metadata for a given file
  class FileParamBuilder
    # @return [Hash<Symbol, Object>]
    def self.build(objectfile:, file_access:, version:, mimetype:, use: 'master', preserve: true)
      new(objectfile:, file_access:, version:, mimetype:, use:, preserve:).build
    end

    def initialize(objectfile:, version:, file_access:, mimetype:, use: 'master', preserve: true)
      @objectfile = objectfile
      @version = version
      @file_access = file_access
      @mimetype = mimetype
      @use = use
      @preserve = preserve
    end

    attr_reader :objectfile, :version, :file_access, :mimetype, :use, :preserve

    def build
      {
        type: 'https://cocina.sul.stanford.edu/models/file',
        externalIdentifier: "https://cocina.sul.stanford.edu/file/#{SecureRandom.uuid}",
        label: objectfile.filename,
        filename: objectfile.filename,
        size: objectfile.filesize,
        version:,
        hasMimeType: mimetype || objectfile.mimetype,
        use:,
        hasMessageDigests: [
          {
            type: 'sha1',
            digest: objectfile.sha1
          },
          {
            type: 'md5',
            digest: objectfile.md5
          }
        ],
        access: file_access,
        administrative: {
          publish: true,
          sdrPreserve: preserve,
          shelve: true
        }
      }
    end
  end
end
