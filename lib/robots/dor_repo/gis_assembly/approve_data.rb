# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class ApproveData < Base
        def initialize
          super('gisAssemblyWF', 'approve-data', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] _druid -- the Druid identifier for the object to process
        def perform(_druid)
          raise 'not implemented'
        end
      end
    end
  end
end
