module Robots
  module DorRepo
    module Demo

      class B2Second
        include LyberCore::Robot

        def initialize
          super('dor', 'demoWf', 'b2-second')
        end

        def perform(druid)
          LyberCore::Log.info "b2-second worked on #{druid}"
        end
      end

    end
  end
end