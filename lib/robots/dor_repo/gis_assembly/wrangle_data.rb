# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class WrangleData < Base
        def initialize
          super('gisAssemblyWF', 'wrangle-data')
        end

        def perform_work
          logger.debug "wrangle-data working on #{bare_druid}"

          rootdir = GisRobotSuite.locate_druid_path bare_druid, type: :stage

          # see if we've already created a data.zip
          datafn = "#{rootdir}/content/data.zip"
          if File.size?(datafn)
            logger.info "wrangle-data: #{bare_druid} found existing data.zip"
            return
          end

          # ensure that we have either a .shp or a .tif or grid
          fn = Dir.glob(File.join(rootdir, 'temp', '*.shp')).first
          if fn.nil?
            fn = Dir.glob(File.join(rootdir, 'temp', '*.tif')).first
            if fn.nil?
              fn = Dir.glob(File.join(rootdir, 'temp', '*', 'metadata.xml')).first
              raise "wrangle-data: #{bare_druid} is missing Shapefile or GeoTIFF or ArcGRID data files" if fn.nil?
            end
          end
          logger.debug "wrangle-data: #{bare_druid} found #{fn}"
        end
      end
    end
  end
end
