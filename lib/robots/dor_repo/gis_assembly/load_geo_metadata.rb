# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class LoadGeoMetadata < Base
        def initialize
          super('gisAssemblyWF', 'load-geo-metadata', check_queued_status: true) # init LyberCore::Robot
        end

        TAG_GIS = 'Dataset : GIS'
        def tag(druid)
          current_tags = tags_client(druid).list
          return if current_tags.include?(TAG_GIS)

          tags_client(druid).create(tags: [TAG_GIS])
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid_without_namespace = druid.delete_prefix('druid:')
          LyberCore::Log.debug "load-geo-metadata: #{druid} working"

          rootdir = GisRobotSuite.locate_druid_path druid_without_namespace, type: :stage

          # Locate geoMetadata datastream
          fn = File.join(rootdir, 'metadata', 'geoMetadata.xml')
          raise "load-geo-metadata: #{druid_without_namespace} cannot locate geoMetadata: #{fn}" unless File.size?(fn)

          client = Dor::Services::Client.object(druid)
          cocina = client.find
          updated = cocina.new(
            type: Cocina::Models::ObjectType.geo,
            geographic: { iso19139: File.read(fn) }
          )
          # Load geoMetadata into DOR
          client.update(params: updated)

          tag druid
        end

        private

        def tags_client(pid)
          Dor::Services::Client.object(pid).administrative_tags
        end
      end
    end
  end
end
