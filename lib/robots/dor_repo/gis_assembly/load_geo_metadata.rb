# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisAssembly   # This is your workflow package name (using CamelCase)
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
          druid_without_namespace = GisRobotSuite.initialize_robot druid
          LyberCore::Log.debug "load-geo-metadata: #{druid} working"

          rootdir = GisRobotSuite.locate_druid_path druid_without_namespace, type: :stage

          # Locate geoMetadata datastream
          fn = File.join(rootdir, 'metadata', 'geoMetadata.xml')
          fail "load-geo-metadata: #{druid_without_namespace} cannot locate geoMetadata: #{fn}" unless File.size?(fn)

          # Load geoMetadata into DOR
          Dor::Services::Client.object(druid).metadata.legacy_update(
            geo: {
              updated: File.mtime(fn),
              content: File.read(fn)
            }
          )

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
