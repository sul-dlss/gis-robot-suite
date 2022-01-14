# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class WrangleData < Base
        def initialize
          super('gisAssemblyWF', 'wrangle-data', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid = druid.delete_prefix('druid:')
          LyberCore::Log.debug "wrangle-data working on #{druid}"

          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage

          # see if we've already created a data.zip
          datafn = "#{rootdir}/content/data.zip"
          if File.size?(datafn)
            LyberCore::Log.info "wrangle-data: #{druid} found existing data.zip"
            return
          end

          # ensure that we have either a .shp or a .tif or grid
          fn = Dir.glob(File.join(rootdir, 'temp', '*.shp')).first
          if fn.nil?
            fn = Dir.glob(File.join(rootdir, 'temp', '*.tif')).first
            if fn.nil?
              fn = Dir.glob(File.join(rootdir, 'temp', '*', 'metadata.xml')).first
              if fn.nil?
                raise "wrangle-data: #{druid} is missing Shapefile or GeoTIFF or ArcGRID data files"
              end
            end
          end
          LyberCore::Log.debug "wrangle-data: #{druid} found #{fn}"
        end
      end
    end
  end
end
