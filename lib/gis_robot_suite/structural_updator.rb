# frozen_string_literal: true

module GisRobotSuite
  class StructuralUpdator
    FILESET_NAMESPACE = 'https://cocina.sul.stanford.edu/fileset/'
    FILE_NAMESPACE = 'https://cocina.sul.stanford.edu/file/'

    def initialize(cocina_object)
      @cocina_object = cocina_object
    end

    attr_reader :cocina_object

    delegate :version, to: :cocina_object

    # @return [Cocina::Models::DRO] the updated DRO with the new file added to the structural contains
    def add_file(filename:, mimetype:, use:, preserve: true)
      cocina_object.new(structural: structural_with(filename:, mimetype:, use:, preserve:))
    end

    private

    def structural_with(filename:, mimetype:, use:, preserve: true)
      files = file_set.structural.contains.to_a

      objectfile = Assembly::ObjectFile.new(filename)
      file_params = GisRobotSuite::FileParamBuilder.build(objectfile:, file_access:, version:, mimetype:, use:, preserve:)
      file = Cocina::Models::File.new(file_params)

      new_file_set = file_set.new(structural: { contains: files + [file] })
      cocina_object.structural.new(contains: [new_file_set])
    end

    # Large assumption here: There is only one file set in the structural contains
    def file_set
      @file_set ||= cocina_object.structural.contains.first.presence || default_file_set
    end

    def default_file_set
      Cocina::Models::FileSet.new(
        type: 'https://cocina.sul.stanford.edu/models/resources/object',
        externalIdentifier: FILESET_NAMESPACE + SecureRandom.uuid,
        label: '',
        version: cocina_object.version
      )
    end

    def file_access
      @file_access ||= cocina_object.access.to_h
                                    .slice(:view, :download, :location, :controlledDigitalLending)
                                    .tap do |access|
        access[:view] = 'dark' if access[:view] == 'citation-only'
      end
    end
  end
end
