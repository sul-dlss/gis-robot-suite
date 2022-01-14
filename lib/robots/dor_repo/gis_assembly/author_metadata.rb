# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class AuthorMetadata < Base

        def initialize
          super('gisAssemblyWF', 'author-metadata', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid = druid.delete_prefix('druid:')
          LyberCore::Log.debug "author-metadata working on #{druid}"

          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage

          # Search for geoMetadata or ESRI metadata
          fn = File.join(rootdir, 'metadata', 'geoMetadata.xml')
          unless File.size?(fn)
            fn = GisRobotSuite.locate_esri_metadata "#{rootdir}/temp"
            raise "author-metadata: #{druid} is missing ESRI metadata files" if fn.nil?
          end

          LyberCore::Log.debug "author-metadata found #{fn}"
        end
      end
    end
  end
end
