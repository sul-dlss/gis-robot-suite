# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisDelivery   # This is your workflow package name (using CamelCase)

      class LoadRaster # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 

        def initialize
          super('dor', 'gisDeliveryWF', 'load-raster', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "load-raster working on #{druid}"
          
          rootdir = GisRobotSuite.locate_druid_path druid, type: :workspace
          
          # determine whether we have a Raster to load
          modsfn = File.join(rootdir, 'metadata', 'descMetadata.xml')
          raise RuntimeError, "Cannot locate MODS: #{modsfn}" unless File.exists?(modsfn)
          format = GisRobotSuite::determine_file_format_from_mods modsfn
          raise RuntimeError, "Cannot determine file format from MODS: #{modsfn}" if format.nil?
          
          # perform based on file format information
          mimetype = format.split(/;/).first # nix mimetype flags
          unless mimetype == 'image/tiff'
            LyberCore::Log.info "#{druid} is not GeoTIFF: #{mimetype}"
            return
          end
          
          # extract derivative 4326 nomalized content
          zipfn = File.join(rootdir, 'content', 'data_EPSG_4326.zip')
          raise RuntimeError, "Cannot locate normalized data: #{zipfn}" unless File.exists?(zipfn)
          tmpdir = extract_data_from_zip druid, zipfn, Dor::Config.geohydra.tmpdir
          
          begin
            Dir.chdir(tmpdir)
            tiffn = Dir.glob("*.tif").first
            raise RuntimeError, "Cannot locate GeoTIFF: #{tmpdir}" if tiffn.nil?
            cmd = "rsync -v #{tiffn} #{Dor::Config.geotiff.dir}/#{druid}.tif"
            LyberCore::Log.debug "Running: #{cmd}"
            system(cmd)
          ensure
            LyberCore::Log.debug "Cleaning: #{tmpdir}"
            FileUtils.rm_rf tmpdir
          end
        end
        
        def extract_data_from_zip druid, zipfn, tmpdir
          LyberCore::Log.debug "Extracting #{druid} data from #{zipfn}"
          
          tmpdir = File.join(tmpdir, "loadraster_#{druid}")
          FileUtils.rm_rf tmpdir if File.directory? tmpdir
          FileUtils.mkdir_p tmpdir
          system("unzip '#{zipfn}' -d '#{tmpdir}'")
          tmpdir
        end
      end
    end
  end
end
