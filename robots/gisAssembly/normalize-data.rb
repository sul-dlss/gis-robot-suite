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
        
        def extract_data_from_zip druid, zipfn, tmpdir
          LyberCore::Log.debug "Extracting #{druid} data from #{zipfn}"
          
          tmpdir = File.join(tmpdir, "normalize_#{druid}")
          FileUtils.rm_rf tmpdir if File.directory? tmpdir
          FileUtils.mkdir_p tmpdir
          system("unzip '#{zipfn}' -d '#{tmpdir}'")
          tmpdir
        end
        
        def reproject_geotiff druid, zipfn, flags, srid = 4326
          tmpdir = extract_data_from_zip druid, zipfn, flags[:tmpdir]
          
          # sniff out GeoTIFF file
          tiffname = nil
          Dir.glob("#{tmpdir}/*.tif.xml") do |fn|
            tiffname = File.basename(fn, '.tif.xml')
          end
          if tiffname.nil?
            LyberCore::Log.debug  "Removing #{tmpdir}"
            FileUtils.rm_rf tmpdir
            raise ArgumentError, "Cannot locate GeoTIFF in #{tmpdir}" 
          end

          # reproject with gdalwarp
          ifn = "#{tmpdir}/#{tiffname}.tif"
          ofn = "#{tmpdir}/EPSG_#{srid}/#{tiffname}.tif"
          FileUtils.mkdir_p(File.dirname(ofn)) unless File.directory?(File.dirname(ofn))
          system "gdalwarp -t_srs EPSG:#{srid} #{ifn} #{ofn} -co 'COMPRESS=LZW'"
          raise RuntimeError, "gdalwarp failed to create #{ofn}" unless File.exists?(ofn)
          
          # package up reprojection
          ozip = File.join(File.dirname(zipfn), "data_EPSG_#{srid}.zip")
          FileUtils.rm_f(ozip) if File.exists?(ozip)
          LyberCore::Log.debug  "Repacking #{ozip}"
          system("zip -q -Dj '#{ozip}' #{ofn}")
          
          # cleanup
          LyberCore::Log.debug  "Removing #{tmpdir}"
          FileUtils.rm_rf tmpdir
        end

        def reproject_arcgrid druid, zipfn, flags, srid = 4326
          tmpdir = extract_data_from_zip druid, zipfn, flags[:tmpdir]
          
          # Sniff out ArcGRID location
          gridname = nil
          Dir.glob("#{tmpdir}/*/metadata.xml") do |fn|
            gridname = File.basename(File.dirname(fn))
          end
          if gridname.nil?
            LyberCore::Log.debug  "Removing #{tmpdir}"
            FileUtils.rm_rf tmpdir
            raise ArgumentError, "Cannot locate ArcGRID in #{tmpdir}" 
          end
          
          # reproject with gdalwarp
          gridfn = "#{tmpdir}/#{gridname}"
          tifffn = "#{tmpdir}/#{gridname}.tif"
          system "gdalwarp -t_srs EPSG:#{srid} #{gridfn} #{tifffn} -co 'COMPRESS=LZW'"
          
          # package up reprojection
          ozip = File.join(File.dirname(zipfn), "data_EPSG_#{srid}.zip")
          FileUtils.rm_f(ozip) if File.exists?(ozip)
          LyberCore::Log.debug  "Repacking #{ozip}"
          system("zip -q -Dj '#{ozip}' #{tifffn}")
          
          # cleanup
          LyberCore::Log.debug  "Removing #{tmpdir}"
          FileUtils.rm_rf tmpdir
        end
        
        # @param zipfn [String] ZIP file
        def reproject_shapefile druid, zipfn, flags, srid = 4326
          tmpdir = extract_data_from_zip druid, zipfn, flags[:tmpdir]
      
          # Sniff out Shapefile location
          shpname = nil
          Dir.glob("#{tmpdir}/*.shp") do |fn|
            shpname = File.basename(fn, '.shp')
          end
          if shpname.nil?
            LyberCore::Log.debug  "Removing #{tmpdir}"
            FileUtils.rm_rf tmpdir
            raise RuntimeError, "Cannot locate Shapefile in #{tmpdir}" 
          end
    
          # setup
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
          
          # Determine file format
          modsfn = "#{rootdir}/metadata/descMetadata.xml"
          raise RuntimeError, "Missing MODS metadata in #{rootdir}" unless File.exists?(modsfn)
          format = GisRobotSuite::determine_file_format_from_mods modsfn
          format = format.split(/;/).first # nix mimetype flags
          case format
          when 'application/x-esri-shapefile'
            reproject_shapefile druid, fn, flags 
          when 'image/tiff' 
            begin
              reproject_geotiff druid, fn, flags
            rescue ArgumentError => e
              # XXX: need format MIME type for ArcGRID in the MODS metadata
              # for now, just try GeoTIFF first and then failover to ArcGRID
              # this causes the zip file to be unpacked twice though
              reproject_arcgrid druid, fn, flags              
            end
          else
            raise NotImplementedError, "Unsupported file format: #{format}"
          end
        end
      end

    end
  end
end

