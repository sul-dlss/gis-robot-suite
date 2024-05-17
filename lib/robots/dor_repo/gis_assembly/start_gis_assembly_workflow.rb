# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      # Kicks off GIS assembly by making sure the item is open
      class StartGisAssemblyWorkflow < Base
        def initialize
          super('gisAssemblyWF', 'start-gis-assembly-workflow')
        end

        def perform_work
          raise 'GIS assembly has been started with an object that is not open' unless object_client.version.status.open?
        end
      end
    end
  end
end
