# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisAssembly   # This is your workflow package name (using CamelCase)

      class ApproveMetadata # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 

        def initialize
          super('dor', 'gisAssemblyWF', 'approve-metadata', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "approve-metadata working on #{druid}"

          rootdir = GisRobotSuite.druid_path druid, type: :stage
          raise RuntimeError, "Missing #{rootdir}" unless File.directory?(rootdir)

          # XXX: Use magic(5) to determine validity
          fn = GisRobotSuite.locate_esri_metadata "#{rootdir}/temp"         
          raise RuntimeError, "Missing ESRI metadata files in #{rootdir}/temp" if fn.nil?

          LyberCore::Log.debug "approve-metadata found #{fn}"
        end
      end

    end
  end
end
