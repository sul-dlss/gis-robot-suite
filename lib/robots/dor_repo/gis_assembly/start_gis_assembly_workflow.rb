# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      # Kicks off GIS assembly by making sure the item is open
      class StartGisAssemblyWorkflow < Base
        def initialize
          super('gisAssemblyWF', 'start-gis-assembly-workflow')
        end

        def perform_work
          raise 'GIS assembly has been started with an object that is not open' unless object_client.version.status.open?
          return unless has_image_tiff?(cocina_object)

          object_client.update(params: update_mimetypes(cocina_object))
        end

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
  end
end
