# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class FinishData < Base
        def initialize
          super('gisAssemblyWF', 'finish-data')
        end

        def perform_work
          logger.debug "finish-data working on #{bare_druid}"

          rootdir = GisRobotSuite.locate_druid_path bare_druid, type: :stage
          %w[data.zip data_EPSG_4326.zip].each do |zipname|
            zipfn = File.join(rootdir, 'content', zipname)
            raise "finish-data: #{bare_druid} is missing packaged data for #{zipname}" unless File.size?(zipfn)

            logger.info "finish-data: #{bare_druid} found #{zipname} #{File.size(zipfn)} bytes"
          end
        end
      end
    end
  end
end
