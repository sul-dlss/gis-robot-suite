# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisDelivery   # This is your workflow package name (using CamelCase)

      class FinishGisDeliveryWorkflow # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 

        def initialize
          super('dor', 'gisDeliveryWF', 'finish-gis-delivery-workflow', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid = GisRobotSuite.initialize_robot druid
          LyberCore::Log.debug "finish-gis-delivery-workflow working on #{druid}"
          
          # Connect to GeoServer
          catalog = RGeoServer::catalog
          LyberCore::Log.debug "Connected to #{catalog}"
          
          # Verify layer
          layer = RGeoServer::Layer.new catalog, name: druid.to_s
          raise RuntimeError, "finish-gis-delivery-workflow: #{druid} is missing GeoServer layer" if layer.new?
        end
      end

    end
  end
end
