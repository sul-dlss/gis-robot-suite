# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class FinishData < Base
        def initialize
          super('gisAssemblyWF', 'finish-data', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid = druid.delete_prefix('druid:')
          LyberCore::Log.debug "finish-data working on #{druid}"

          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage
          %w[data.zip data_EPSG_4326.zip].each do |zipname|
            zipfn = File.join(rootdir, 'content', zipname)
            if File.size?(zipfn)
              LyberCore::Log.info "finish-data: #{druid} found #{zipname} #{File.size(zipfn)} bytes"
            else
              raise "finish-data: #{druid} is missing packaged data for #{zipname}"
            end
          end
        end
      end
    end
  end
end
