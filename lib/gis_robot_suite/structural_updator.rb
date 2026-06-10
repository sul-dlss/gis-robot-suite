# frozen_string_literal: true

module GisRobotSuite
  class StructuralUpdator
    def initialize(cocina_object)
      @cocina_object = cocina_object
    end

    attr_reader :cocina_object

    delegate :version, to: :cocina_object

    # @return [Cocina::Models::DRO] the updated DRO with the new file added to the structural contains
    def add_file(filename:, use:, file_set:, mimetype: nil, preserve: true, presentation: nil)
      @cocina_object = cocina_object.new(structural: structural_with_file(filename:, mimetype:, use:, preserve:, file_set:, presentation:))
    end

    # @return [Cocina::Models::DRO] the updated DRO with the matching files removed from the structural contains
    def remove_files(use:, file_set:, mimetype: nil)
      @cocina_object = cocina_object.new(structural: structural_without_files(use:, mimetype:, file_set:))
    end

    private

    def structural_with_file(filename:, mimetype:, use:, file_set:, preserve: true, presentation: nil)
      objectfile = Assembly::ObjectFile.new(filename)
      file_params = if presentation
                      GisRobotSuite::ImageFileParamBuilder.build(objectfile:, file_access:, version:, mimetype:, use:, preserve:, presentation:)
                    else
                      GisRobotSuite::FileParamBuilder.build(objectfile:, file_access:, version:, mimetype:, use:, preserve:)
                    end
      file = Cocina::Models::File.new(file_params)

      current_fs = find_file_set(file_set)
      new_file_set = current_fs.new(structural: current_fs.structural.new(contains: current_fs.structural.contains + [file]))

      update_structural_with_file_set(new_file_set)
    end

    def structural_without_files(use:, file_set:, mimetype: nil)
      current_fs = find_file_set(file_set)
      new_contains = current_fs.structural.contains.reject do |file|
        file.use == use && (mimetype.nil? || file.hasMimeType == mimetype)
      end
      new_file_set = current_fs.new(structural: current_fs.structural.new(contains: new_contains))

      update_structural_with_file_set(new_file_set)
    end

    def find_file_set(file_set)
      cocina_object.structural.contains.find { |fs| fs.externalIdentifier == file_set.externalIdentifier } || file_set
    end

    def update_structural_with_file_set(new_file_set)
      new_contains = if cocina_object.structural.contains.empty?
                       [new_file_set]
                     else
                       cocina_object.structural.contains.map do |fs|
                         fs.externalIdentifier == new_file_set.externalIdentifier ? new_file_set : fs
                       end
                     end
      # Ensure the new file set is added if it wasn't there
      new_contains << new_file_set unless new_contains.any? { |fs| fs.externalIdentifier == new_file_set.externalIdentifier }

      cocina_object.structural.new(contains: new_contains)
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
