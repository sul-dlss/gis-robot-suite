Robot-Suite-Base
---------

This is a baseline robot project using the new `robot-master`/`robot-controller`/`lyber-core` framework, which builds upon `resque` for job-management. The idea is that if you're creating a new robot suite, you would fork this repo as a starting point.

An example robot as found in `robots/myDemo/a1_first.rb` looks like this
```ruby
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
```

See the [Wiki](https://github.com/sul-dlss/robot-suite-base/wiki) for further details.
