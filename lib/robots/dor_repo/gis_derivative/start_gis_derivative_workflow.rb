# frozen_string_literal: true

module Robots
  module DorRepo
    module GisDerivative
      # Kicks off GIS derivative by making sure the item is open
      class StartGisDerivativeWorkflow < Base
        def initialize
          super('gisDerivativeWF', 'start-gis-derivative-workflow')
        end

        def perform_work
          raise 'GIS derivative has been started with an object that is not open' unless object_client.version.status.open?
        end
      end
    end
  end
end
