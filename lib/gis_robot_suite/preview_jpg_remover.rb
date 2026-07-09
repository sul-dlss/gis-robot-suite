# frozen_string_literal: true

module GisRobotSuite
  # Removes the file named "preview.jpg" from an object's structural metadata and
  # consolidates all remaining files into a single file set. Geo objects should have
  # exactly one file set containing all of their files; any empty file sets are dropped.
  class PreviewJpgRemover
    FILENAME = 'preview.jpg'

    def initialize(logger: nil)
      @logger = logger || Logger.new($stdout)
    end

    def self.run(druid:, logger: nil)
      new(logger:).run(druid:)
    end

    def run(druid:)
      bare_druid = druid.delete_prefix('druid:')
      @logger.info "Processing druid:#{bare_druid}..."

      object_client = Dor::Services::Client.object("druid:#{bare_druid}")
      cocina_object = object_client.find

      unless needs_update?(cocina_object)
        @logger.info "  Nothing to update for druid:#{bare_druid} (no #{FILENAME} and already a single file set)."
        return
      end

      @logger.info "  Opening new version for druid:#{bare_druid}..."
      # Open a new version. Note: object_client.version.open returns the Cocina representation of the opened version.
      opened_cocina = object_client.version.open(description: "Remove #{FILENAME} and consolidate files into a single file set")

      @logger.info "  Removing #{FILENAME} and consolidating file sets..."
      updated_cocina = consolidate_files(opened_cocina)

      @logger.info '  Saving updated Cocina object...'
      object_client.update(params: updated_cocina)

      @logger.info '  Closing version...'
      object_client.version.close
      @logger.info "  Successfully updated druid:#{bare_druid}."
    rescue StandardError => e
      @logger.error "  Failed to process druid:#{bare_druid}: #{e.message}"
      raise
    end

    private

    def needs_update?(cocina_object)
      file_sets = cocina_object.structural.contains
      return true if file_sets.size > 1

      file_sets.any? do |file_set|
        file_set.structural.contains.any? { |file| file.filename == FILENAME }
      end
    end

    # Removes preview.jpg and moves every remaining file into the first file set,
    # leaving the object with a single file set and no empty ones.
    def consolidate_files(cocina_object)
      file_sets = cocina_object.structural.contains
      first_file_set = file_sets.first

      consolidated_files = file_sets.flat_map do |file_set|
        file_set.structural.contains.reject { |file| file.filename == FILENAME }
      end

      new_first_file_set = first_file_set.new(
        structural: first_file_set.structural.new(contains: consolidated_files)
      )

      cocina_object.new(structural: cocina_object.structural.new(contains: [new_first_file_set]))
    end
  end
end
