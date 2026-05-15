# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class StartDerivativeWorkflow < Base
        def initialize
          super('gisAssemblyWF', 'start-derivative-workflow')
        end

        def perform_work
          current_version = object_client.version.current
          object_client.workflow('gisDerivativeWF').create(version: current_version)
        end
      end
    end
  end
end
