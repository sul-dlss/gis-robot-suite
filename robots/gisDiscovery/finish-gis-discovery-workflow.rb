# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisDiscovery   # This is your workflow package name (using CamelCase)

      class FinishGisDiscoveryWorkflow # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 

        def initialize
          super('dor', 'gisDiscoveryWF', 'finish-gis-discovery-workflow', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid = GisRobotSuite.initialize_robot druid
          LyberCore::Log.debug "finish-gis-discovery-workflow working on #{druid}"
          
          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage
          
          xmlfn = File.join(rootdir, 'metadata', 'geoblacklight.xml')
          raise RuntimeError, "finish-gis-discovery-workflow: #{druid} cannot locate GeoBlacklight metadata: #{xmlfn}" unless File.size?(xmlfn)
          
          # XXX: check Solr index too
        end
      end

    end
  end
end
