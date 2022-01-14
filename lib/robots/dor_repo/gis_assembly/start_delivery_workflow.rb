# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class StartDeliveryWorkflow < Base
        def initialize
          super('gisAssemblyWF', 'start-delivery-workflow', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid = druid.delete_prefix('druid:')
          LyberCore::Log.debug "start-delivery-workflow working on #{druid}"
          object_client = Dor::Services::Client.object(druid)
          current_version = object_client.version.current
          workflow_service.create_workflow_by_name("druid:#{druid}", 'gisDeliveryWF', version: current_version)
        end
      end
    end
  end
end
