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
          raise RuntimeError, "normalize-data: #{druid} cannot locate packaged data: #{zipfn}" unless File.exists?(zipfn)
          
          tmpdir = File.join(tmpdir, "normalize_#{druid}")
          FileUtils.rm_rf tmpdir if File.directory? tmpdir
          FileUtils.mkdir_p tmpdir
          system("unzip '#{zipfn}' -d '#{tmpdir}'")
          tmpdir
        end
        
        def reproject_geotiff druid, zipfn, proj, flags, srid = 4326
          tmpdir = extract_data_from_zip druid, zipfn, flags[:tmpdir]
          
          # sniff out GeoTIFF file
          tiffname = nil
          Dir.glob("#{tmpdir}/*.tif.xml") do |fn|
            tiffname = File.basename(fn, '.tif.xml')
          end
          if tiffname.nil?
            LyberCore::Log.debug "Removing #{tmpdir}"
            FileUtils.rm_rf tmpdir
            raise ArgumentError, "normalize-data: #{druid} cannot locate GeoTIFF in #{tmpdir}" 
          end

          ifn = "#{tmpdir}/#{tiffname}.tif"
          ofn = "#{tmpdir}/EPSG_#{srid}/#{tiffname}.tif"
          FileUtils.mkdir_p(File.dirname(ofn)) unless File.directory?(File.dirname(ofn))
          unless proj == "EPSG:#{srid}"
            tempfn = "#{File.dirname(ofn)}/#{tiffname}_uncompressed.tif"
            
            # reproject with gdalwarp (must uncompress here to prevent bloat)
            LyberCore::Log.info "Reprojecting #{ifn} -> #{tempfn}"
            system "gdalwarp -t_srs EPSG:#{srid} #{ifn} #{tempfn} -co 'COMPRESS=NONE'"
            raise RuntimeError, "normalize-data: #{druid} gdalwarp failed to create #{tempfn}" unless File.exists?(tempfn)
            
            # compress tempfn with gdal_translate
            LyberCore::Log.info "Compressing #{tempfn} -> #{ofn}"
            system "gdal_translate -a_srs EPSG:#{srid} #{tempfn} #{ofn} -co 'COMPRESS=LZW'"
            FileUtils.rm_f(tempfn)
            raise RuntimeError, "normalize-data: #{druid} gdal_translate failed to create #{ofn}" unless File.exists?(ofn)
          else
            # compress with gdal_translate
            LyberCore::Log.info "Compressing #{ifn} -> #{ofn}"
            system "gdal_translate -a_srs EPSG:#{srid} #{ifn} #{ofn} -co 'COMPRESS=LZW'"
            raise RuntimeError, "normalize-data: #{druid} gdal_translate failed to create #{ofn}" unless File.exists?(ofn)
          end
          
          # package up reprojection
          ozip = File.join(File.dirname(zipfn), "data_EPSG_#{srid}.zip")
          FileUtils.rm_f(ozip) if File.exists?(ozip)
          LyberCore::Log.debug  "Repacking #{ozip}"
          system("zip -Dj '#{ozip}' #{ofn}")
          
          # cleanup
          LyberCore::Log.debug "Removing #{tmpdir}"
          FileUtils.rm_rf tmpdir
        end

        def reproject_arcgrid druid, zipfn, proj, flags, srid = 4326
          tmpdir = extract_data_from_zip druid, zipfn, flags[:tmpdir]
          
          # Sniff out ArcGRID location
          gridname = nil
          Dir.glob("#{tmpdir}/*/metadata.xml") do |fn|
            gridname = File.basename(File.dirname(fn))
          end
          if gridname.nil?
            LyberCore::Log.debug "Removing #{tmpdir}"
            FileUtils.rm_rf tmpdir
            raise ArgumentError, "normalize-data: #{druid} cannot locate ArcGRID in #{tmpdir}"
          end
          
          gridfn = "#{tmpdir}/#{gridname}"
          tifffn = "#{tmpdir}/#{gridname}.tif"
          
          unless proj == "EPSG:#{srid}"
            warpflags = ''
            unless flags[:wkt][proj.to_s.gsub(/^EPSG:/, '')].nil?
              warpflags = "-s_srs '#{proj}'" # we know the source WKT for this so use it
            end
            # reproject with gdalwarp (must uncompress here to prevent bloat)
            tempfn = "#{tmpdir}/#{gridname}_uncompressed.tif"
            LyberCore::Log.info "Reprojecting #{gridfn}"
            cmd = "gdalwarp #{warpflags} -t_srs EPSG:#{srid} #{gridfn} #{tempfn}"
            LyberCore::Log.debug "Running: #{cmd}"
            system cmd
            raise RuntimeError, "normalize-data: #{druid} gdalwarp failed to create #{tempfn}" unless File.exists?(tempfn)
          
            # compress GeoTIFF
            LyberCore::Log.info "Compressing #{tempfn} -> #{tifffn}"
            system "gdal_translate -a_srs EPSG:#{srid} #{tempfn} #{tifffn} -co 'COMPRESS=LZW'"
            FileUtils.rm_f(tempfn)
            raise RuntimeError, "normalize-data: #{druid} gdal_translate failed to create #{tifffn}" unless File.exists?(tifffn)
          else
            # translate and compress GeoTIFF
            LyberCore::Log.info "Translating and Compressing #{gridfn}"
            system "gdal_translate -a_srs EPSG:#{srid} #{gridfn} #{tifffn} -co 'COMPRESS=LZW'"
            raise RuntimeError, "normalize-data: #{druid} gdal_translate failed to create #{tifffn}" unless File.exists?(tifffn)
          end
          
          # package up reprojection
          ozip = File.join(File.dirname(zipfn), "data_EPSG_#{srid}.zip")
          FileUtils.rm_f(ozip) if File.exists?(ozip)
          LyberCore::Log.debug  "Repacking #{ozip}"
          system("zip -Dj '#{ozip}' #{tifffn}")
          
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
            LyberCore::Log.debug "Removing #{tmpdir}"
            FileUtils.rm_rf tmpdir
            raise RuntimeError, "normalize-data: #{druid} cannot locate Shapefile in #{tmpdir}" 
          end
    
          # setup
          wkt = flags[:wkt][srid.to_s]
          ifn = File.join(tmpdir, "#{shpname}.shp") # input shapefile
          raise RuntimeError, "#{ifn} is missing" unless File.exist? ifn
      
          odr = File.join(tmpdir, "EPSG_#{srid}") # output directory
          ofn = File.join(odr, "#{shpname}.shp")  # output shapefile
          
          # Verify source projection
          prjfn = File.join(tmpdir, "#{shpname}.prj")
          unless File.exists?(prjfn)
            LyberCore::Log.warn "normalize-data: #{druid} is missing projection #{prjfn}, assuming EPSG:#{srid}" 
            ogr_flags = "-s_srs '#{wkt}'"
          else
            ogr_flags = ''
          end

          # reproject, @see http://www.gdal.org/ogr2ogr.html
          FileUtils.mkdir_p odr unless File.directory? odr
          LyberCore::Log.info "Projecting #{ifn} -> #{ofn}"
          system("ogr2ogr -progress #{ogr_flags} -t_srs '#{wkt}' '#{ofn}' '#{ifn}'") 
          raise RuntimeError, "normalize-data: #{druid} failed to reproject #{ifn}" unless File.exists?(ofn)
          
          # normalize prj file
          if flags[:overwrite_prj] && wkt
            prj_fn = ofn.gsub('.shp', '.prj')
            LyberCore::Log.debug "Overwriting #{prj_fn}"
            File.open(prj_fn, 'w') {|f| f.write(wkt)}
          end

          # package up reprojection
          ozip = File.join(File.dirname(zipfn), "data_EPSG_#{srid}.zip")
          FileUtils.rm_f(ozip) if File.exists?(ozip)
          LyberCore::Log.debug "Repacking #{ozip}"
          system("zip -Dj '#{ozip}' \"#{odr}/#{shpname}\".*")

          # cleanup
          LyberCore::Log.debug "Removing #{tmpdir}"
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
          
          datafn = "#{rootdir}/content/data_EPSG_4326.zip"
          if File.exists?(datafn)
            LyberCore::Log.info "Found normalized data: #{datafn}"
            return
          end
          
          File.umask(002)
          flags = {
            :overwrite_prj => true,
            :tmpdir => Dor::Config.geohydra.tmpdir,
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
              }.split.join.freeze,
              '54009' => %Q{
                PROJCS["World_Mollweide",
                    GEOGCS["GCS_WGS_1984",
                        DATUM["WGS_1984",
                            SPHEROID["WGS_1984",6378137,298.257223563]],
                        PRIMEM["Greenwich",0],
                        UNIT["Degree",0.017453292519943295]],
                    PROJECTION["Mollweide"],
                    PARAMETER["False_Easting",0],
                    PARAMETER["False_Northing",0],
                    PARAMETER["Central_Meridian",0],
                    UNIT["Meter",1],
                    AUTHORITY["EPSG","54009"]]
              }.split.join.freeze
            }
          }
          
          fn = "#{rootdir}/content/data.zip" # original content
          LyberCore::Log.debug "Processing #{druid} #{fn}"
          
          # Determine file format
          modsfn = "#{rootdir}/metadata/descMetadata.xml"
          raise RuntimeError, "normalize-data: #{druid} is missing MODS metadata" unless File.exists?(modsfn)
          format = GisRobotSuite::determine_file_format_from_mods modsfn
          raise RuntimeError, "normalize-data: #{druid} cannot determine file format from MODS" if format.nil?
          
          # reproject based on file format information
          mimetype = format.split(/;/).first # nix mimetype flags
          case mimetype
          when 'application/x-esri-shapefile'
            reproject_shapefile druid, fn, flags 
          when 'image/tiff'
            proj = GisRobotSuite.determine_projection_from_mods modsfn
            proj.gsub!('ESRI', 'EPSG')
            LyberCore::Log.debug "Projection = #{proj}"
            filetype = format.split(/format=/)[1]
            if filetype == 'GeoTIFF'
              reproject_geotiff druid, fn, proj, flags
            elsif filetype == 'ArcGRID'
              reproject_arcgrid druid, fn, proj, flags              
            else
              raise NotImplementedError, "normalize-data: #{druid} has unsupported Raster file format: #{format}"
            end
          else
            raise NotImplementedError, "normalize-data: #{druid} has unsupported file format: #{format}"
          end
        end
      end
    end
  end
end

