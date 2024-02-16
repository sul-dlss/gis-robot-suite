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

          raise "load-vector: #{bare_druid} cannot determine media type" unless GisRobotSuite.media_type(cocina_object)

          # perform based on file format information
          unless GisRobotSuite.vector?(cocina_object)
            logger.info "load-vector: #{bare_druid} is not a vector, skipping"
            return
          end

          normalizer.with_normalized do |tmpdir|
            schema = Settings.geohydra.postgis.schema || 'druid'
            # encoding =  # XXX: these are hardcoded encodings for certain druids -- these should be read from the metadata somewhere
            #   case druid
            #   when 'bt348dh6363', 'cc936tf6277'
            #     'LATIN1'
            #   else
            #     'UTF-8'
            #   end

            # sniff out shapefile from extraction
            Dir.chdir(tmpdir) do
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
            end

            # Load the data into PostGIS
            cmd = 'psql --no-psqlrc --no-password --quiet ' \
                  "--file='#{sqlfn}' "
            logger.debug "Running: #{cmd}"
            system(cmd, exception: true)
          end
        end

        private

        def normalizer
          GisRobotSuite::VectorNormalizer.new(logger:, bare_druid:, rootdir:)
        end

        def rootdir
          @rootdir ||= GisRobotSuite.locate_druid_path bare_druid, type: :workspace
        end
      end
    end
  end
end
