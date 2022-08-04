# frozen_string_literal: true

module Robots
  module DorRepo
    module GisDelivery
      class ResetGeowebcache < Base
        def initialize
          super('gisDeliveryWF', 'reset-geowebcache', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "reset-geowebcache working on #{druid}"

          rights = GisRobotSuite.determine_rights(druid.delete_prefix('druid:')).downcase
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
              LyberCore::Log.warn(e.message)
            end
          end
        end
      end
    end
  end
end
