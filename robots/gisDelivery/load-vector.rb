# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisDelivery   # This is your workflow package name (using CamelCase)

      class LoadVector # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 

        def initialize
          super('dor', 'gisDeliveryWF', 'load-vector', check_queued_status: true) # init LyberCore::Robot
        end

        def extract_data_from_zip druid, zipfn, tmpdir
          LyberCore::Log.info "load-vector: #{druid} is extracting data: #{zipfn}"
          
          tmpdir = File.join(tmpdir, "loadvector_#{druid}")
          FileUtils.rm_rf tmpdir if File.directory? tmpdir
          FileUtils.mkdir_p tmpdir
          system("unzip '#{zipfn}' -d '#{tmpdir}'")
          tmpdir
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "load-vector working on #{druid}"

          rootdir = GisRobotSuite.locate_druid_path druid, type: :workspace
          
          # determine whether we have a Shapefile to load
          modsfn = File.join(rootdir, 'metadata', 'descMetadata.xml')
          raise RuntimeError, "load-vector: #{druid} cannot locate MODS: #{modsfn}" unless File.exists?(modsfn)
          format = GisRobotSuite::determine_file_format_from_mods modsfn
          raise RuntimeError, "load-vector: #{druid} cannot determine file format from MODS" if format.nil?
          
          # perform based on file format information
          mimetype = format.split(/;/).first # nix mimetype flags
          unless mimetype == GisRobotSuite.determine_mimetype(:vector)
            if mimetype == GisRobotSuite.determine_mimetype(:raster)
              LyberCore::Log.info "load-vector: #{druid} is raster, skipping"
            else
              LyberCore::Log.warn "load-vector: #{druid} is not Shapefile: #{mimetype}"
            end
            return
          end
          
          # extract derivative 4326 nomalized content
          projection = '4326' # always use EPSG:4326 derivative
          zipfn = File.join(rootdir, 'content', "data_EPSG_#{projection}.zip")
          raise RuntimeError, "load-vector: #{druid} cannot locate normalized data: #{zipfn}" unless File.exists?(zipfn)
          tmpdir = extract_data_from_zip druid, zipfn, Dor::Config.geohydra.tmpdir
          raise RuntimeError, "load-vector: #{druid} cannot locate #{tmpdir}" unless File.directory?(tmpdir)
          
          begin
            schema = Dor::Config.geohydra.postgis.schema || 'druid'
            encoding = 'UTF-8'
            
            # sniff out shapefile from extraction
            Dir.chdir(tmpdir)
            shpfn = Dir.glob("*.shp").first
            sqlfn = shpfn.gsub(/\.shp$/, '.sql')
            LyberCore::Log.debug "load-vector: #{druid} is working on Shapefile: #{shpfn}"

            # XXX: Perhaps put the .sql data into the content directory as .zip for derivative
            # XXX: -G for the geography column causes some issues with GeoServer
            cmd = "shp2pgsql -s #{projection} -d -D -I -W #{encoding}" +
                   " '#{shpfn}' #{schema}.#{druid} " +
                   "> '#{sqlfn}'"
            LyberCore::Log.debug "Running: #{cmd}"
            system(cmd)
            
            if File.exists?(sqlfn)
              cmd = 'psql --no-psqlrc --no-password --quiet ' +
                     "--file='#{sqlfn}' "
              LyberCore::Log.debug "Running: #{cmd}"
              system(cmd)
            else
              raise RuntimeError, "load-vector: #{druid} shp2pgsql failed to load #{schema}.#{druid}"
            end 
          ensure
            LyberCore::Log.debug "Cleaning: #{tmpdir}"
            FileUtils.rm_rf tmpdir
          end          
        end
      end

    end
  end
end
