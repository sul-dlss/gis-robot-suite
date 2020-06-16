# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisAssembly   # This is your workflow package name (using CamelCase)
      class ApproveData < Base
        def initialize
          super('gisAssemblyWF', 'approve-data', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] _druid -- the Druid identifier for the object to process
        def perform(_druid)
          fail 'not implemented'
        end
      end
    end
  end
end
