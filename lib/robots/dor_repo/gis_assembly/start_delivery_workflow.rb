# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class StartDeliveryWorkflow < Base
        def initialize
          super('gisAssemblyWF', 'start-delivery-workflow')
        end

        def perform_work
          logger.debug "start-delivery-workflow working on #{bare_druid}"
          current_version = object_client.version.current
          object_client.workflow('gisDeliveryWF').create(version: current_version)
        end
      end
    end
  end
end
