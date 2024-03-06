# frozen_string_literal: true

require 'fileutils'

module Robots
  module DorRepo
    module GisDelivery
      class MetadataCleanup < Base
        def initialize
          super('gisDeliveryWF', 'metadata-cleanup')
        end

        def perform_work
          logger.debug "metadata-cleanup working on #{bare_druid}"
          stage_dir = GisRobotSuite.locate_druid_path bare_druid, type: :stage
          content_dir = File.join(stage_dir, 'content')
          FileUtils.rm_f Dir.glob("#{content_dir}/*") # remove all the files (not directories)
          remove_empty_druid_path_parts(content_dir) if File.directory?(content_dir)
        end

        private

        def remove_empty_druid_path_parts(druid_path)
          return unless File.directory?(druid_path) && Dir.empty?(druid_path)
          return if druid_path == Settings.geohydra.stage # don't remove the stage directory

          FileUtils.rm_rf(druid_path) # remove the emtpy directory
          remove_empty_druid_path_parts(File.dirname(druid_path)) # remove parent directory if it's empty
        end
      end
    end
  end
end
