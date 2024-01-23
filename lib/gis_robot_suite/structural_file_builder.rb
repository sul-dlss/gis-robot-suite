# frozen_string_literal: true

module GisRobotSuite
  # Builds cocina file metadata
  class StructuralFileBuilder
    def self.build(*args)
      new(*args).build
    end

    # @param [Hash<Symbol,Assembly::ObjectFile>] objects
    def initialize(assembly_objectfile, access, version)
      @assembly_objectfile = assembly_objectfile
      @access = access
      @version = version
    end

    attr_reader :assembly_objectfile, :access, :version

    def build
      Cocina::Models::File.new(file_attributes)
    end

    private

    def file_attributes
      {
        hasMimeType: mimetype,
        administrative: { publish: true, shelve: true, sdrPreserve: roletype_for_file == 'master' },
        access: access,
        externalIdentifier: "https://cocina.sul.stanford.edu/file/#{SecureRandom.uuid}",
        type: Cocina::Models::ObjectType.file,
        version: version,
        filename: assembly_objectfile.filename,
        label: assembly_objectfile.filename,
        size: assembly_objectfile.filesize,
        use: roletype_for_file || 'master',
        hasMessageDigests: [
          { type: 'sha1', digest: assembly_objectfile.sha1 },
          { type: 'md5', digest: assembly_objectfile.md5 }
        ]
      }
    end

    def mimetype
      @mimetype ||= assembly_objectfile.mimetype
    end

    def roletype_for_file
      @roletype_for_file ||= if mimetype == 'application/zip'
                               if assembly_objectfile.path =~ /_(EPSG_\d+)/i # derivative
                                 'derivative'
                               else
                                 'master'
                               end
                             end
    end
  end
end
