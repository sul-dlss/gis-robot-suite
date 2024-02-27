# frozen_string_literal: true

require 'fileutils'

module Robots
  module DorRepo
    module GisAssembly
      class FinishGisAssemblyWorkflow < Base
        def initialize
          super('gisAssemblyWF', 'finish-gis-assembly-workflow')
        end

        def perform_work
          logger.debug "finish-gis-assembly-workflow working on #{bare_druid}"
          rootdir = GisRobotSuite.locate_druid_path bare_druid, type: :stage

          # delete all staged files in temp/
          tmpdir = "#{rootdir}/temp"
          if File.directory?(tmpdir)
            logger.debug "finish-gis-assembly-workflow deleting #{tmpdir}"
            FileUtils.rm_r(tmpdir)
          end

          # load workspace with identical copy of stage
          destdir = GisRobotSuite.locate_druid_path bare_druid, type: :workspace
          FileUtils.mkdir_p(destdir) unless File.directory?(destdir)
          logger.info "finish-gis-assembly-workflow: #{bare_druid} migrating object to #{destdir} from #{rootdir}"
          FileUtils.cp_r("#{rootdir}/.", destdir)
          FileUtils.rm_f(rootdir)
        end
      end
    end
  end
end
