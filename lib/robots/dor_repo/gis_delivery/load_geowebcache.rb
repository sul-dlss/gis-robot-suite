# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisDelivery   # This is your workflow package name (using CamelCase)
      class LoadGeowebcache < Base
        def initialize
          super('gisDeliveryWF', 'load-geowebcache', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "load-geowebcache working on #{druid}"

          fail 'not implemented' # XXX: load to external geowebcache registry if needed
        end
      end
    end
  end
end
