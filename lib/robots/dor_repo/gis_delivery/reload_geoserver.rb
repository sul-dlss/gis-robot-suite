# frozen_string_literal: true

module Robots
  module DorRepo
    module GisDelivery
      class ReloadGeoserver < Base
        def initialize
          super('gisDeliveryWF', 'reload-geoserver')
        end

        def perform_work
          logger.debug "reload-geoserver working on #{druid}"

          rights = GisRobotSuite.determine_rights(cocina_object)
          ##
          # Reload each server configured
          Settings.geoserver[rights].map do |_key, setting|
            next unless setting[:url]

            connection = Geoserver::Publish::Connection.new(
              {
                # Use the Geoserver REST endpoint to reset
                'url' => setting[:url],
                'user' => setting[:user],
                'password' => setting[:password]
              }
            )
            begin
              connection.post(path: '/reload', payload: nil)
            rescue Geoserver::Publish::Error => e
              logger.warn(e.message)
            end
          end
        end
      end
    end
  end
end
