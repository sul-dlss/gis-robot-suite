# frozen_string_literal: true

module GisRobotSuite
  # Removes a00000001.TablesByName.atx entries from Cocina structural metadata.
  # Files on disk and the object's version state are not changed.
  class TablesByNameAtxRemover
    FILENAME = 'a00000001.TablesByName.atx'

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
      updated_cocina = remove_files(cocina_object)

      if updated_cocina == cocina_object
        @logger.info "  Nothing to update for druid:#{bare_druid}."
        return
      end

      @logger.info "  Removing #{FILENAME} and saving updated Cocina object..."
      object_client.update(params: updated_cocina)
      @logger.info "  Successfully updated druid:#{bare_druid}."
    rescue StandardError => e
      @logger.error "  Failed to process druid:#{bare_druid}: #{e.message}"
      raise
    end

    private

    def remove_files(cocina_object)
      updated_file_sets = cocina_object.structural.contains.filter_map do |file_set|
        files = file_set.structural.contains.reject { |file| File.basename(file.filename) == FILENAME }
        next if files.empty?

        file_set.new(structural: file_set.structural.new(contains: files))
      end

      return cocina_object if updated_file_sets == cocina_object.structural.contains

      cocina_object.new(structural: cocina_object.structural.new(contains: updated_file_sets))
    end
  end
end
