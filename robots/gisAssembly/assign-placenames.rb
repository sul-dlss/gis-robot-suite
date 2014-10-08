# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisAssembly   # This is your workflow package name (using CamelCase)

      class AssignPlacenames # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 

        def initialize
          super('dor', 'gisAssemblyWF', 'assign-placenames', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "assign-placenames working on #{druid}"
          
          rootdir = GisRobotSuite.druid_path druid, type: :stage
          raise RuntimeError, "Missing #{rootdir}" unless File.directory?(rootdir)
          
          # XXX: rewrite MODS with gazetteer mappings for placenames
          raise NotImplementedError
        end
      end

    end
  end
end
