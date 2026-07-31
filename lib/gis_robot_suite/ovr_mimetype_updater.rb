# frozen_string_literal: true

module GisRobotSuite
  class OvrMimetypeUpdater
    MIME_TYPE = 'application/octet-stream'

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

      unless has_ovr_file?(cocina_object)
        @logger.info "  No .ovr files found for druid:#{bare_druid}."
        return
      end

      version_was_open = object_client.version.status.open?
      if version_was_open
        @logger.info "  Using existing open version for druid:#{bare_druid}..."
        editable_cocina = cocina_object
      else
        @logger.info "  Opening new version for druid:#{bare_druid}..."
        editable_cocina = object_client.version.open(
          description: 'Set .ovr file mimetype to application/octet-stream'
        )
      end

      @logger.info '  Adjusting mimetypes...'
      updated_cocina = update_mimetypes(editable_cocina)

      @logger.info '  Saving updated Cocina object...'
      object_client.update(params: updated_cocina)

      unless version_was_open
        @logger.info '  Closing version...'
        object_client.version.close
      end
      @logger.info "  Successfully updated druid:#{bare_druid}."
    rescue StandardError => e
      @logger.error "  Failed to process druid:#{bare_druid}: #{e.message}"
      raise
    end

    private

    def has_ovr_file?(cocina_object) # rubocop:disable Naming/PredicatePrefix
      return false unless cocina_object.respond_to?(:structural) && cocina_object.structural&.contains

      cocina_object.structural.contains.any? do |file_set|
        files(file_set).any? { |file| ovr_file?(file) }
      end
    end

    def update_mimetypes(cocina_object)
      new_contains = cocina_object.structural.contains.map do |file_set|
        next file_set unless file_set.respond_to?(:structural) && file_set.structural&.contains

        new_files = files(file_set).map do |file|
          ovr_file?(file) ? file.new(hasMimeType: MIME_TYPE) : file
        end

        file_set.new(structural: file_set.structural.new(contains: new_files))
      end

      cocina_object.new(structural: cocina_object.structural.new(contains: new_contains))
    end

    def files(file_set)
      return [] unless file_set.respond_to?(:structural) && file_set.structural&.contains

      file_set.structural.contains
    end

    def ovr_file?(file)
      File.extname(file.filename).casecmp?('.ovr')
    end
  end
end
