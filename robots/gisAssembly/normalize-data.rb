# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisAssembly   # This is your workflow package name (using CamelCase)

      class NormalizeData # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 

        def initialize
          super('dor', 'gisAssemblyWF', 'normalize-data', check_queued_status: true) # init LyberCore::Robot
        end
        
        # @param zipfn [String] ZIP file
        def reproject_shapefile druid, zipfn, flags
          LyberCore::Log.debug "Extracting #{druid} data from #{zipfn}"
          
          tmpdir = "#{flags[:tmpdir]}/normalize_#{druid}"
          FileUtils.rm_rf tmpdir if File.directory? tmpdir
          FileUtils.mkdir_p tmpdir
          system("unzip -j '#{zipfn}' -d '#{tmpdir}'")
      
          shpname = nil
          Dir.glob("#{tmpdir}/*.shp") do |fn|
            shpname = File.basename(fn, '.shp')
          end
          if shpname.nil?
            LyberCore::Log.debug  "Removing #{tmpdir}"
            FileUtils.rm_rf tmpdir
            raise RuntimeError, "Cannot locate Shapefile in #{tmpdir}" 
          end
      
          [4326].each do |srid|
            wkt = flags[:wkt][srid.to_s]
            
            ifn = File.join(tmpdir, "#{shpname}.shp") # input shapefile
            raise RuntimeError, "#{ifn} is missing" unless File.exist? ifn
        
            odr = File.join(tmpdir, "EPSG_#{srid}") # output directory
            ofn = File.join(odr, "#{shpname}.shp")  # output shapefile
            LyberCore::Log.debug "Projecting #{ifn} -> #{ofn}"

            # reproject, @see http://www.gdal.org/ogr2ogr.html
            FileUtils.mkdir_p odr unless File.directory? odr
            system("ogr2ogr -progress -t_srs '#{wkt}' '#{ofn}' '#{ifn}'") 
            raise RuntimeError, "Failed to reproject #{ifn}" unless File.exists?(ofn)
            
            # normalize prj file
            if flags[:overwrite_prj] && wkt
              prj_fn = ofn.gsub('.shp', '.prj')
              LyberCore::Log.debug "Overwriting #{prj_fn}"
              File.open(prj_fn, 'w') {|f| f.write(wkt)}
            end

            # package up reprojection
            ozip = File.join(File.dirname(zipfn), "data_EPSG_#{srid}.zip")
            FileUtils.rm_f(ozip) if File.exists?(ozip)
            LyberCore::Log.debug  "Repacking #{ozip}"
            system("zip -q -Dj '#{ozip}' \"#{odr}/#{shpname}\".*")

            # cleanup
            LyberCore::Log.debug  "Removing #{odr}"
            # FileUtils.rm_rf odr
          end

          # cleanup
          LyberCore::Log.debug  "Removing #{tmpdir}"
          FileUtils.rm_rf tmpdir
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "normalize-data working on #{druid}"
          
          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage
          LyberCore::Log.debug "Using rootdir=#{rootdir}"
          
          File.umask(002)
          flags = {
            :overwrite_prj => true,
            :tmpdir => "#{rootdir}/temp",
            #
            # ogr2ogr is using a different WKT than GeoServer -- this one is from GeoServer 2.3.1.
            # As implemented by EPSG database on HSQL:
            #  http://docs.geotools.org/latest/userguide/library/referencing/hsql.html
            # Also see:
            #  http://spatialreference.org/ref/epsg/4326/prettywkt/
            #
            :wkt => {
              '4326' => %Q{
              GEOGCS["WGS 84",
                  DATUM["WGS_1984",
                      SPHEROID["WGS 84",6378137,298.257223563,
                          AUTHORITY["EPSG","7030"]],
                      AUTHORITY["EPSG","6326"]],
                  PRIMEM["Greenwich",0,
                      AUTHORITY["EPSG","8901"]],
                  UNIT["degree",0.01745329251994328,
                      AUTHORITY["EPSG","9122"]],
                  AUTHORITY["EPSG","4326"]]
              }.split.join.freeze
            }

          }  

          fn = "#{rootdir}/content/data.zip" # original content
          LyberCore::Log.debug "Processing #{druid} #{fn}"
          reproject_shapefile druid, fn, flags 
        end
      end

    end
  end
end

