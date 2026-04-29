# frozen_string_literal: true

module GisRobotSuite
  # This class is responsible for building the list of Cocina Files (there is only one) for the preview image.
  class PreviewFileBuilder
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
        GisRobotSuite::ImageFileParamBuilder.build(
          objectfile:,
          file_access:,
          version:,
          mimetype: 'image/jpeg',
          presentation:
        )
      ]
    end

    private

    def preview_path
      @preview_path ||= File.join(content_dir, 'preview.jpg')
    end

    def objectfile
      raise "Missing preview file: #{preview_path}" unless File.exist?(preview_path)

      Assembly::ObjectFile.new(preview_path)
    end

    def presentation
      wh = FastImage.size(preview_path)
      { width: wh[0], height: wh[1] }
    end
  end
end
