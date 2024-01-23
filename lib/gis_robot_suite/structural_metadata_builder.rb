# frozen_string_literal: true

module GisRobotSuite
  class StructuralMetadataBuilder
    def self.build(*args)
      new(*args).build
    end

    # @param [String] druid
    # @param [Hash{Symbol=>Array<Assembly::ObjectFile>}] object_files lists of assembly object files, keyed by file_category
    def initialize(cocina_model, druid, object_files)
      @cocina_model = cocina_model
      @druid = druid
      @object_files = object_files
    end

    attr_reader :cocina_model, :druid, :object_files

    def build
      cocina_model.structural.new(contains: file_sets)
    end

    private

    def file_access
      @file_access ||= cocina_model.access.to_h
                                   .slice(:view, :download, :location, :controlledDigitalLending)
                                   .tap do |access|
        access[:view] = 'dark' if access[:view] == 'citation-only'
      end
    end

    # @return [Array<Cocina::Models::FileSet>]
    def file_sets
      object_files.compact_blank.map.with_index(1) do |(file_category, assembly_objectfiles), seq|
        files = assembly_objectfiles.map do |assembly_objectfile|
          builder_for(assembly_objectfile).build(assembly_objectfile, file_access, cocina_model.version)
        end

        Cocina::Models::FileSet.new(
          externalIdentifier: "#{druid}_#{seq}",
          version: cocina_model.version,
          type: resource_type(file_category),
          label: file_category.to_s,
          structural: {
            contains: files
          }
        )
      end
    end

    def builder_for(assembly_objectfile)
      assembly_objectfile.image? ? ImageFileBuilder : StructuralFileBuilder
    end

    def resource_type(file_category)
      case file_category
      when :Data
        Cocina::Models::FileSetType.object
      when :Preview
        Cocina::Models::FileSetType.preview
      else
        Cocina::Models::FileSetType.attachment
      end
    end
  end
end
