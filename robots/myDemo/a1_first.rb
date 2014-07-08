# Robot class to run under multiplexing infrastructure

module Robots
  module DorRepo    # Use DorRepo to avoid name collision with Dor module
    module MyDemo   # This is your workflow package name (using CamelCase)

      class A1First # This is your robot name
        include LyberCore::Robot # this is the base robot implementation

        def initialize
          super('dor', 'myDemoWF', 'a1-first') # calls LyberCore::Robot initialize
        end

        # perform is the main entry point for the robot
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          # ... your robot work goes here ...
          LyberCore::Log.info "a1-first worked on #{druid}"
        end
      end

    end
  end
end
