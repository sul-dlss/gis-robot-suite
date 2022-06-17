# frozen_string_literal: true

module GisRobotSuite
  class StructuralMetadataBuilder
    def self.build(*args)
      new(*args).build
    end

    # @param [String] druid
    # @param [Hash<Symbol,Assembly::ObjectFile>] objects
    def initialize(cocina_model, druid, objects)
      @cocina_model = cocina_model
      @druid = druid
      @objects = objects
    end

    attr_reader :cocina_model, :druid, :objects

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
      objects.compact_blank.map.with_index(1) do |(key, value), seq|
        files = value.map do |assembly_objectfile|
          builder_for(assembly_objectfile).build(assembly_objectfile, file_access, cocina_model.version)
        end

        Cocina::Models::FileSet.new(
          externalIdentifier: "#{druid}_#{seq}",
          version: cocina_model.version,
          type: resource_type(key),
          label: key.to_s,
          structural: {
            contains: files
          }
        )
      end
    end

    def builder_for(assembly_objectfile)
      assembly_objectfile.image? ? ImageFileBuilder : StructuralFileBuilder
    end

    def resource_type(key)
      case key
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
