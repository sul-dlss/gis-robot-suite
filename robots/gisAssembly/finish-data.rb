# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisAssembly   # This is your workflow package name (using CamelCase)

      class FinishData # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 

        def initialize
          super('dor', 'gisAssemblyWF', 'finish-data', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "finish-data working on #{druid}"

          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage
          %w{data.zip data_EPSG_4326.zip}.each do |zipname|
            zipfn = File.join(rootdir, 'content', zipname)
            if File.readable?(zipfn) && File.size(zipfn) > 0
              LyberCore::Log.info "finish-data found #{zipfn}"
            else
              raise RuntimeError, "finish-data: #{druid} is missing packaged data for #{zipname}"
            end
          end
        end
      end

    end
  end
end
