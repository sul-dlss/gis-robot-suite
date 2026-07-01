# frozen_string_literal: true

module GisRobotSuite
  class GeotiffMimetypeUpdater
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

      unless has_image_tiff?(cocina_object)
        @logger.info "  No image/tiff files found for druid:#{bare_druid}."
        return
      end

      @logger.info "  Opening new version for druid:#{bare_druid}..."
      # Open a new version. Note: object_client.version.open returns the Cocina representation of the opened version.
      opened_cocina = object_client.version.open(description: 'Update image/tiff mimetype to image/tiff; application=geotiff')

      @logger.info '  Adjusting mimetypes...'
      updated_cocina = update_mimetypes(opened_cocina)

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

    def has_image_tiff?(cocina_object) # rubocop:disable Naming/PredicatePrefix
      return false unless cocina_object.respond_to?(:structural) && cocina_object.structural&.contains

      cocina_object.structural.contains.any? do |file_set|
        file_set.respond_to?(:structural) && file_set.structural && file_set.structural.contains&.any? do |file|
          file.hasMimeType == 'image/tiff'
        end
      end
    end

    def update_mimetypes(cocina_object)
      new_contains = cocina_object.structural.contains.map do |file_set|
        next file_set unless file_set.respond_to?(:structural) && file_set.structural && file_set.structural.contains

        new_files = file_set.structural.contains.map do |file|
          if file.hasMimeType == 'image/tiff'
            file.new(hasMimeType: 'image/tiff; application=geotiff')
          else
            file
          end
        end

        file_set.new(structural: file_set.structural.new(contains: new_files))
      end

      cocina_object.new(structural: cocina_object.structural.new(contains: new_contains))
    end
  end
end
