# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisAssembly   # This is your workflow package name (using CamelCase)

      class ApproveData # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 

        def initialize
          super('dor', 'gisAssemblyWF', 'approve-data', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "approve-data working on #{druid}"

          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage
          
          # see if we've already created a data.zip
          datafn = "#{rootdir}/content/data.zip"
          if File.exists?(datafn)
            LyberCore::Log.info "Found packaged data: #{datafn}"
            return
          end

          # XXX: Use magic(5) to determine validity
          fn = Dir.glob("#{rootdir}/temp/*.shp").first # Shapefile
          if fn.nil? or File.size(fn) == 0
            fn = Dir.glob("#{rootdir}/temp/*.tif").first # GeoTIFF
            if fn.nil? or File.size(fn) == 0
              fn = Dir.glob("#{rootdir}/temp/*/metadata.xml").first # ArcGRID
              if fn.nil? or File.size(fn) == 0
                raise RuntimeError, "Missing data files in #{rootdir}/temp"
              end
            end
          end
          LyberCore::Log.debug "approve-data found #{fn}"
        end
      end

    end
  end
end
