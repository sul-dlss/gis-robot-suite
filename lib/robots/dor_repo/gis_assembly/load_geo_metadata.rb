# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class LoadGeoMetadata < Base
        def initialize
          super('gisAssemblyWF', 'load-geo-metadata')
        end

        def perform_work
          bare_druid = druid.delete_prefix('druid:')
          logger.debug "load-geo-metadata: #{druid} working"

          rootdir = GisRobotSuite.locate_druid_path bare_druid, type: :stage

          # Locate geoMetadata xml file
          fn = File.join(rootdir, 'metadata', 'geoMetadata.xml')
          raise "load-geo-metadata: #{bare_druid} cannot locate geoMetadata: #{fn}" unless File.size?(fn)

          updated = cocina_object.new(
            type: Cocina::Models::ObjectType.geo,
            geographic: { iso19139: File.read(fn) }
          )
          # Load geoMetadata into DOR
          object_client.update(params: updated)

          tag
        end

        private

        TAG_GIS = 'Dataset : GIS'
        def tag
          current_tags = tags_client.list
          return if current_tags.include?(TAG_GIS)

          tags_client.create(tags: [TAG_GIS])
        end

        def tags_client
          object_client.administrative_tags
        end
      end
    end
  end
end
