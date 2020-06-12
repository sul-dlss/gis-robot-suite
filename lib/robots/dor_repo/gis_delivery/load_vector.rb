# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisDelivery   # This is your workflow package name (using CamelCase)
      class LoadVector # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot

        def initialize
          super('gisDeliveryWF', 'load-vector', check_queued_status: true) # init LyberCore::Robot
        end

        def extract_data_from_zip(druid, zipfn, tmpdir)
          LyberCore::Log.info "load-vector: #{druid} is extracting data: #{zipfn}"

          tmpdir = File.join(tmpdir, "loadvector_#{druid}")
          FileUtils.rm_rf tmpdir if File.directory? tmpdir
          FileUtils.mkdir_p tmpdir
          system("unzip '#{zipfn}' -d '#{tmpdir}'")
          tmpdir
        end

        def run_shp2pgsql(projection, encoding, shpfn, schema, druid, sqlfn, errfn)
          # XXX: Perhaps put the .sql data into the content directory as .zip for derivative
          # XXX: -G for the geography column causes some issues with GeoServer
          cmd = "shp2pgsql -s #{projection} -d -D -I -W #{encoding}" \
                 " '#{shpfn}' #{schema}.#{druid} " \
                 "> '#{sqlfn}' 2> '#{errfn}'"
          LyberCore::Log.debug "Running: #{cmd}"
          success = system(cmd)
          fail "load-vector: #{druid} cannot convert Shapefile to PostGIS: #{File.open(errfn).readlines}" unless success
          fail "load-vector: #{druid} shp2pgsql generated no SQL?" unless File.size?(sqlfn)
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid = GisRobotSuite.initialize_robot druid
          LyberCore::Log.debug "load-vector working on #{druid}"

          rootdir = GisRobotSuite.locate_druid_path druid, type: :workspace

          # determine whether we have a Shapefile to load
          modsfn = File.join(rootdir, 'metadata', 'descMetadata.xml')
          fail "load-vector: #{druid} cannot locate MODS: #{modsfn}" unless File.size?(modsfn)
          format = GisRobotSuite.determine_file_format_from_mods modsfn
          fail "load-vector: #{druid} cannot determine file format from MODS" if format.nil?

          # perform based on file format information
          unless GisRobotSuite.vector?(format)
            LyberCore::Log.info "load-vector: #{druid} is not a vector, skipping"
            return
          end

          # extract derivative 4326 nomalized content
          projection = '4326' # always use EPSG:4326 derivative
          zipfn = File.join(rootdir, 'content', "data_EPSG_#{projection}.zip")
          fail "load-vector: #{druid} cannot locate normalized data: #{zipfn}" unless File.size?(zipfn)
          tmpdir = extract_data_from_zip druid, zipfn, Settings.geohydra.tmpdir
          fail "load-vector: #{druid} cannot locate #{tmpdir}" unless File.directory?(tmpdir)

          begin
            schema = Settings.geohydra.postgis.schema || 'druid'
            # encoding =  # XXX: these are hardcoded encodings for certain druids -- these should be read from the metadata somewhere
            #   case druid
            #   when 'bt348dh6363', 'cc936tf6277'
            #     'LATIN1'
            #   else
            #     'UTF-8'
            #   end

            # sniff out shapefile from extraction
            Dir.chdir(tmpdir)
            shpfn = Dir.glob('*.shp').first
            sqlfn = shpfn.gsub(/\.shp$/, '.sql')
            errfn = 'shp2pgsql.err'
            LyberCore::Log.debug "load-vector: #{druid} is working on Shapefile: #{shpfn}"

            # first try decoding with UTF-8 and if that fails use LATIN1
            begin
              run_shp2pgsql(projection, 'UTF-8', shpfn, schema, druid, sqlfn, errfn)
            rescue RuntimeError => e
              run_shp2pgsql(projection, 'LATIN1', shpfn, schema, druid, sqlfn, errfn)
            end

            # Load the data into PostGIS
            cmd = 'psql --no-psqlrc --no-password --quiet ' \
                   "--file='#{sqlfn}' "
            LyberCore::Log.debug "Running: #{cmd}"
            success = system(cmd)
            fail "load-vector: #{druid} psql failed to load #{schema}.#{druid}" unless success
          ensure
            LyberCore::Log.debug "Cleaning: #{tmpdir}"
            FileUtils.rm_rf tmpdir
          end
        end
      end
    end
  end
end
