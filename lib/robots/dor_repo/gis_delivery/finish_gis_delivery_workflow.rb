# frozen_string_literal: true

module Robots
  module DorRepo
    module GisDelivery
      class FinishGisDeliveryWorkflow < Base
        def initialize
          super('gisDeliveryWF', 'finish-gis-delivery-workflow', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid = druid.delete_prefix('druid:')
          LyberCore::Log.debug "finish-gis-delivery-workflow working on #{druid}"

          # Connect to both the public and restricted GeoServers to verify layer
          # exists
          available_in_geoserver = Settings.geoserver.map do |_key, setting|
            connection = Geoserver::Publish::Connection.new(
              {
                'url' => setting[:primary][:url],
                'user' => setting[:primary][:user],
                'password' => setting[:primary][:password]
              }
            )
            Geoserver::Publish::Layer.new(connection).find(layer_name: druid)
          end
          raise "finish-gis-delivery-workflow: #{druid} is missing GeoServer layer" unless available_in_geoserver.any?
        end
      end
    end
  end
end
