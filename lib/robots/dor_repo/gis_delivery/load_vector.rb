# frozen_string_literal: true

module Robots
  module DorRepo
    module GisDelivery
      class LoadVector < Base
        def initialize
          super('gisDeliveryWF', 'load-vector')
        end

        def perform_work
          logger.debug "load-vector working on #{bare_druid}"

          rootdir = GisRobotSuite.locate_druid_path bare_druid, type: :workspace

          # determine whether we have a Shapefile to load
          modsfn = File.join(rootdir, 'metadata', 'descMetadata.xml')
          raise "load-vector: #{bare_druid} cannot locate MODS: #{modsfn}" unless File.size?(modsfn)

          raise "load-vector: #{bare_druid} cannot determine media type" unless GisRobotSuite.media_type(cocina_object)

          # perform based on file format information
          unless GisRobotSuite.vector?(cocina_object)
            logger.info "load-vector: #{bare_druid} is not a vector, skipping"
            return
          end

          # extract derivative 4326 nomalized content
          projection = '4326' # always use EPSG:4326 derivative
          zipfn = File.join(rootdir, 'content', "data_EPSG_#{projection}.zip")
          raise "load-vector: #{bare_druid} cannot locate normalized data: #{zipfn}" unless File.size?(zipfn)

          tmpdir = extract_data_from_zip zipfn, Settings.geohydra.tmpdir
          raise "load-vector: #{bare_druid} cannot locate #{tmpdir}" unless File.directory?(tmpdir)

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
            logger.debug "load-vector: #{bare_druid} is working on Shapefile: #{shpfn}"

            # first try decoding with UTF-8 and if that fails use LATIN1
            begin
              run_shp2pgsql(projection, 'UTF-8', shpfn, schema, sqlfn, errfn)
            rescue RuntimeError
              run_shp2pgsql(projection, 'LATIN1', shpfn, schema, sqlfn, errfn)
            end

            # Load the data into PostGIS
            cmd = 'psql --no-psqlrc --no-password --quiet ' \
                  "--file='#{sqlfn}' "
            logger.debug "Running: #{cmd}"
            system(cmd, exception: true)
          ensure
            logger.debug "Cleaning: #{tmpdir}"
            FileUtils.rm_rf tmpdir
          end
        end

        private

        def extract_data_from_zip(zipfn, tmpdir)
          logger.info "load-vector: #{bare_druid} is extracting data: #{zipfn}"

          tmpdir = File.join(tmpdir, "loadvector_#{bare_druid}")
          FileUtils.rm_rf tmpdir if File.directory? tmpdir
          FileUtils.mkdir_p tmpdir
          system("unzip '#{zipfn}' -d '#{tmpdir}'", exception: true)
          tmpdir
        end

        def run_shp2pgsql(projection, encoding, shpfn, schema, sqlfn, errfn)
          # XXX: Perhaps put the .sql data into the content directory as .zip for derivative
          # XXX: -G for the geography column causes some issues with GeoServer
          cmd = "shp2pgsql -s #{projection} -d -D -I -W #{encoding} " \
                "'#{shpfn}' #{schema}.#{bare_druid} " \
                "> '#{sqlfn}' 2> '#{errfn}'"
          logger.debug "Running: #{cmd}"
          success = system(cmd, exception: true)
          raise "load-vector: #{bare_druid} cannot convert Shapefile to PostGIS: #{File.open(errfn).readlines}" unless success
          raise "load-vector: #{bare_druid} shp2pgsql generated no SQL?" unless File.size?(sqlfn)
        end
      end
    end
  end
end
