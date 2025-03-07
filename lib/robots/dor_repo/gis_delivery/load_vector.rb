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

            # sniff out shapefile from extraction
            shp_filename = Dir.glob("#{tmpdir}/*.shp").first
            sql_filename = shp_filename.gsub(/\.shp$/, '.sql')

            logger.debug "load-vector: #{bare_druid} is working on Shapefile: #{shp_filename}"

            # first try decoding with UTF-8 and if that fails use LATIN1
            # see also https://github.com/sul-dlss/gis-robot-suite/issues/850
            begin
              run_shp2pgsql('4326', 'UTF-8', shp_filename, schema, sql_filename)
            rescue GisRobotSuite::SystemCommandError => e
              logger.warn("#{druid} -- fell through to LATIN1 encoding after calling run_shp2pgsql with " \
                          "UTF-8 encoding and encountering error: #{e.message}; #{e.backtrace.join('; ')}")
              run_shp2pgsql('4326', 'LATIN1', shp_filename, schema, sql_filename)
            end

            # Load the data into PostGIS
            cmd = 'psql --no-psqlrc --no-password --quiet ' \
                  "--file='#{sql_filename}' "
            logger.debug "Running: #{cmd}"
            GisRobotSuite.run_system_command(cmd, logger:)
          end
        end

        private

        def normalizer
          GisRobotSuite::VectorNormalizer.new(logger:, bare_druid:, rootdir:)
        end

        def rootdir
          @rootdir ||= GisRobotSuite.locate_druid_path bare_druid, type: :stage
        end

        def run_shp2pgsql(projection, encoding, shp_filename, schema, sql_filename)
          # TODO: Perhaps put the .sql data into the content directory as .zip for derivative
          # NOTE: -G for the geography column causes some issues with GeoServer
          cmd = "shp2pgsql -s #{projection} -d -D -I -W #{encoding} '#{shp_filename}' #{schema}.#{bare_druid} > '#{sql_filename}'"
          GisRobotSuite.run_system_command(cmd, logger:)
          raise "normalize-vector: #{bare_druid} shp2pgsql generated no SQL?" unless File.size?(sql_filename)
        end
      end
    end
  end
end
