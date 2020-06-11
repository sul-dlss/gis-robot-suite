# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisAssembly   # This is your workflow package name (using CamelCase)
      class StartAssemblyWorkflow # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot

        def initialize
          super('gisAssemblyWF', 'start-assembly-workflow', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid = GisRobotSuite.initialize_robot druid
          LyberCore::Log.debug "start-assembly-workflow working on #{druid}"
          object_client = Dor::Services::Client.object(druid)
          current_version = object_client.version.current
          Dor::Config.workflow.client.create_workflow_by_name("druid:#{druid}", 'assemblyWF', version: current_version)
        end
      end
    end
  end
end
