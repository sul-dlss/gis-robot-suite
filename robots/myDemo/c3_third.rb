module Robots
  module DorRepo
    module MyDemo

      class C3Third
        include LyberCore::Robot

        def initialize
          super('dor', 'myDemoWf', 'c3-third')
        end

        def perform(druid)
          LyberCore::Log.info "c3-third worked on #{druid}"
        end
      end

    end
  end
end
