# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisAssembly   # This is your workflow package name (using CamelCase)

      class WrangleData # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 

        def initialize
          super('dor', 'gisAssemblyWF', 'wrangle-data', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "wrangle-data working on #{druid}"
          
          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage
          
          # see if we've already created a data.zip
          datafn = "#{rootdir}/content/data.zip"
          if File.exists?(datafn)
            LyberCore::Log.info "Found wrangled data: #{datafn}"
            return
          end
          
          # ensure that we have either a .shp or a .tif or grid
          fn = Dir.glob(File.join(rootdir, 'temp', '*.shp')).first
          if fn.nil?
            fn = Dir.glob(File.join(rootdir, 'temp', '*.tif')).first
            if fn.nil?
              fn = Dir.glob(File.join(rootdir, 'temp', '*', 'metadata.xml')).first
              if fn.nil?
                raise RuntimeError, "wrangle-data: #{druid} is missing Shapefile or GeoTIFF or ArcGRID data files"
              end
            end
          end
          LyberCore::Log.debug "wrangle-data found #{fn}"
        end
      end

    end
  end
end
