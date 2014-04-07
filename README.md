Demo-Bots
---------

This is an example robot project using the new `robot-master`/`robot-controller`/`lyber-core` framework, which builds upon `resque` for job-management.

An example robot as found in `robots/demo/a1_first.rb` looks like this
```ruby
module Robots
  module DorRepo
    module Demo

      class A1First
        include LyberCore::Robot

        def initialize
          super('dor', 'demoWf', 'a1-first')
        end

        def perform(druid)
          LyberCore::Log.info "a1-first worked on #{druid}"
        end
      end

    end
  end
end
```
## Configuration

Here are the files you will find in the `config` directory

`config/boot`
Loads supporting framework classes and configuration

`config/environments/bluepill_development.rb`
Configuration options for the `bluepill` process manager

`config/environments/workfows_development.rb`
You list workflow steps that will spawn workers, and optionally, how many workers per step

`config/workflows/demo_definition.xml`
An example of what the `robot-master` would use to determine the completion dependencies between steps

`config/workflows/demo_wf.xml`
How an actual instance of this demo workflow could be initialized in the `workflow-service`

