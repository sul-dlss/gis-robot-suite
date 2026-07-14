# frozen_string_literal: true

module GisRobotSuite
  # Removes Cocina file entries that do not represent files directly in the
  # object's workspace content directory. Files on disk are not changed.
  class SubdirectoryFileRemover
    def initialize(logger: nil)
      @logger = logger || Logger.new($stdout)
    end

    def self.run(druid:, logger: nil)
      new(logger:).run(druid:)
    end

    def run(druid:)
      bare_druid = druid.delete_prefix('druid:')
      @logger.info "Processing druid:#{bare_druid}..."

      content_path = workspace_content_path(bare_druid)
      filenames = direct_file_names(content_path)
      object_client = Dor::Services::Client.object("druid:#{bare_druid}")
      cocina_object = object_client.find
      updated_cocina = remove_unmatched_files(cocina_object, filenames)

      if updated_cocina == cocina_object
        @logger.info "  Nothing to update for druid:#{bare_druid}."
        return
      end

      @logger.info '  Saving updated Cocina object...'
      object_client.update(params: updated_cocina)
      @logger.info "  Successfully updated druid:#{bare_druid}."
    rescue StandardError => e
      @logger.error "  Failed to process druid:#{bare_druid}: #{e.message}"
      raise
    end

    private

    def workspace_content_path(druid)
      content_path = File.join(GisRobotSuite.locate_druid_path(druid, type: :workspace), 'content')
      raise "Missing #{content_path}" unless File.directory?(content_path)

      content_path
    end

    def direct_file_names(content_path)
      Dir.children(content_path).select do |filename|
        File.file?(File.join(content_path, filename))
      end.to_set
    end

    def remove_unmatched_files(cocina_object, filenames)
      updated_file_sets = cocina_object.structural.contains.filter_map do |file_set|
        files = file_set.structural.contains.select { |file| filenames.include?(file.filename) }
        next if files.empty?

        file_set.new(structural: file_set.structural.new(contains: files))
      end

      return cocina_object if updated_file_sets == cocina_object.structural.contains

      cocina_object.new(structural: cocina_object.structural.new(contains: updated_file_sets))
    end
  end
end
