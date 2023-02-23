# frozen_string_literal: true

module Robots
  module DorRepo
    module GisDelivery
      class ResetGeowebcache < Base
        def initialize
          super('gisDeliveryWF', 'reset-geowebcache')
        end

        def perform_work
          logger.debug "reset-geowebcache working on #{druid}"

          rights = GisRobotSuite.determine_rights(bare_druid).downcase
          ##
          # Truncate the cache for the layer in every place
          Settings.geoserver[rights].map do |_key, setting|
            next unless setting[:url]

            connection = Geoserver::Publish::Connection.new(
              {
                # Use the GeoWebCache URI
                'url' => setting[:url]&.gsub('geoserver/rest', 'geoserver/gwc/rest'),
                'user' => setting[:user],
                'password' => setting[:password]
              }
            )
            begin
              Geoserver::Publish::Geowebcache.new(connection).masstruncate(layer_name: druid)
            rescue Geoserver::Publish::Error => e
              logger.warn(e.message)
            end
          end
        end
      end
    end
  end
end
