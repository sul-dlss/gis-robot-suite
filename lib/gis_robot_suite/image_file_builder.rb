# frozen_string_literal: true

module GisRobotSuite
  # A file builder for images
  class ImageFileBuilder < StructuralFileBuilder
    private

    def file_attributes
      wh = FastImage.size(assembly_objectfile.path)
      super.merge(presentation: { width: wh[0], height: wh[1] })
    end

    def mimetype
      @mimetype ||= MIME::Types.type_for("xxx.#{FastImage.type(assembly_objectfile.path)}").first.to_s
    end

    def roletype_for_file
      @roletype_for_file ||= assembly_objectfile.path.ends_with?('_small.png') ? 'derivative' : 'master'
    end
  end
end
