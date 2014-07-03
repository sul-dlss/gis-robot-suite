module Robots
  module DorRepo
    module MyDemo

      class A1First
        include LyberCore::Robot

        def initialize
          super('dor', 'myDemoWf', 'a1-first')
        end

        def perform(druid)
          LyberCore::Log.info "a1-first worked on #{druid}"
        end
      end

    end
  end
end
