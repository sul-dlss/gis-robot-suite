# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class FinishMetadata < Base
        def initialize
          super('gisAssemblyWF', 'finish-metadata')
        end

        def perform_work
          logger.debug "finish-metadata working on #{bare_druid}"

          rootdir = GisRobotSuite.locate_druid_path bare_druid, type: :stage

          %w[descMetadata.xml geoMetadata.xml].each do |f|
            fn = File.join(rootdir, 'metadata', f)
            raise "finish-metadata: #{bare_druid} is missing metadata: #{fn}" unless File.size?(fn)

            logger.info "finish-metadata found #{fn} #{File.size(fn)} bytes"
          end

          %w[preview.jpg].each do |f|
            fn = File.join(rootdir, 'content', f)
            raise "finish-metadata: #{bare_druid} is missing content: #{fn}" unless File.size?(fn)

            logger.info "finish-metadata found #{fn} #{File.size(fn)} bytes"
          end
        end
      end
    end
  end
end
