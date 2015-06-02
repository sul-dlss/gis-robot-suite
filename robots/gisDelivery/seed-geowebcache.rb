# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisDelivery   # This is your workflow package name (using CamelCase)
      class SeedGeowebcache # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot

        def initialize
          super('dor', 'gisDeliveryWF', 'seed-geowebcache', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "seed-geowebcache working on #{druid}"

          base_url = Dor::Config.geohydra.geowebcache.url
          layer_id = 'druid:{druid}'
          uri = "rest/seed/#{layer_id}.xml"
          xml = "
            <seedRequest>
              <name>#{layer_id}</name>
              <srs><number>900913</number></srs>
              <zoomStart>1</zoomStart>
              <zoomStop>8</zoomStop>
              <format>image/png</format>
              <type>seed</type>
              <threadCount>1</threadCount>
            </seedRequest>"

          LyberCore::Log.debug "Connecting to GeoWebCache at #{base_url}/#{uri}"
          RestClient.post "#{base_url}/#{uri}", xml,               user: Dor::Config.geohydra.geowebcache.user,
                                                                   password: Dor::Config.geohydra.geowebcache.password,
                                                                   content_type: :xml
        end
      end
    end
  end
end
