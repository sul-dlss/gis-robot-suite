# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class AuthorMetadata < Base
        def initialize
          super('gisAssemblyWF', 'author-metadata')
        end

        def perform_work
          logger.debug "author-metadata working on #{bare_druid}"

          rootdir = GisRobotSuite.locate_druid_path bare_druid, type: :stage

          # Search for geoMetadata or ESRI metadata
          fn = File.join(rootdir, 'metadata', 'geoMetadata.xml')
          unless File.size?(fn)
            fn = GisRobotSuite.locate_esri_metadata "#{rootdir}/temp"
            raise "author-metadata: #{bare_druid} is missing ESRI metadata files" if fn.nil?
          end

          logger.debug "author-metadata found #{fn}"
        end
      end
    end
  end
end
