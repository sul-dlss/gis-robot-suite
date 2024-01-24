# frozen_string_literal: true

module Robots
  module DorRepo
    module GisDelivery
      class StartAccessionWorkflow < Base
        def initialize
          super('gisDeliveryWF', 'start-accession-workflow')
        end

        def perform_work
          logger.debug "start-accession-workflow working on #{bare_druid}"
          current_version = object_client.version.current
          workflow_service.create_workflow_by_name(druid, 'accessionWF', version: current_version)
        end
      end
    end
  end
end
