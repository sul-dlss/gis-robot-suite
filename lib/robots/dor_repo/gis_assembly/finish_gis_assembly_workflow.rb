# frozen_string_literal: true

require 'fileutils'

module Robots
  module DorRepo
    module GisAssembly
      # FinishGisAssemblyWorkflow moves GIS files from the assembly or staging root into the dor workspace for SDR accessioning
      class FinishGisAssemblyWorkflow < Base
        def initialize
          super('gisAssemblyWF', 'finish-gis-assembly-workflow')
        end

        def perform_work
          logger.debug "finish-gis-assembly-workflow working on #{bare_druid}"
          destdir = GisRobotSuite.locate_druid_path bare_druid, type: :workspace
          staged_content = GisRobotSuite::StagedContent.find(bare_druid)
          return already_moved(destdir) unless staged_content

          rootdir = staged_content.pathname.to_s
          FileUtils.mkdir_p(destdir) unless File.directory?(destdir)

          logger.info "finish-gis-assembly-workflow: #{bare_druid} migrating object to #{destdir} from #{rootdir}"
          FileUtils.cp_r("#{rootdir}/.", destdir)

          # Clean up the staging area after the copy
          FileUtils.rm_rf(rootdir)
        end

        private

        # A retry after a successful copy and cleanup finds the content only in the workspace.
        def already_moved(destdir)
          raise "No staged content for #{bare_druid} in assembly, staging, or workspace" unless File.directory?(destdir)

          LyberCore::ReturnState.new(status: :skipped, note: 'no staged content; already in workspace')
        end
      end
    end
  end
end
