# frozen_string_literal: true

module Robots
  module DorRepo
    module GisDelivery
      class FinishGisDeliveryWorkflow < Base
        def initialize
          super('gisDeliveryWF', 'finish-gis-delivery-workflow')
        end

        def perform_work
          logger.debug "finish-gis-delivery-workflow working on #{bare_druid}"

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
            Geoserver::Publish::Layer.new(connection).find(layer_name: bare_druid)
          end
          raise "finish-gis-delivery-workflow: #{bare_druid} is missing GeoServer layer" unless available_in_geoserver.any?
        end
      end
    end
  end
end
