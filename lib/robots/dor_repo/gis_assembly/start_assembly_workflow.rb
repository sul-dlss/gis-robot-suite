# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class StartAssemblyWorkflow < Base
        def initialize
          super('gisAssemblyWF', 'start-assembly-workflow')
        end

        def perform_work
          logger.debug "start-assembly-workflow working on #{bare_druid}"
          current_version = object_client.version.current
          workflow_service.create_workflow_by_name(druid, 'assemblyWF', version: current_version)
        end
      end
    end
  end
end
