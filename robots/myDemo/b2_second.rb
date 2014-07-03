module Robots
  module DorRepo
    module MyDemo

      class B2Second
        include LyberCore::Robot

        def initialize
          super('dor', 'myDemoWf', 'b2-second')
        end

        def perform(druid)
          LyberCore::Log.info "b2-second worked on #{druid}"
        end
      end

    end
  end
end
