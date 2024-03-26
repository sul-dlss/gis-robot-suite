# frozen_string_literal: true

module Robots
  module DorRepo
    module GisDelivery
      class LoadRaster < Base
        def initialize
          super('gisDeliveryWF', 'load-raster')
        end

        def perform_work
          logger.debug "load-raster working on #{bare_druid}"

          # determine whether we have a Raster to load
          unless GisRobotSuite.raster?(cocina_object)
            logger.info "load-raster: #{bare_druid} is not a raster, skipping"
            return
          end

          normalizer.with_normalized do |tmpdir|
            tif_filename = Dir.glob("#{tmpdir}/*.tif").first
            raise "load-raster: #{bare_druid} cannot locate GeoTIFF: #{tmpdir}" if tif_filename.nil?

            # copy to geoserver storage
            destination_path = if Settings.geohydra.geotiff.host == 'localhost'
                                 Settings.geohydra.geotiff.dir
                               else
                                 [Settings.geohydra.geotiff.host, Settings.geohydra.geotiff.dir].join(':')
                               end
            cmd = "rsync -v '#{tif_filename}' #{destination_path}/#{bare_druid}.tif"
            logger.debug "Running: #{cmd}"
            GisRobotSuite.run_system_command(cmd, logger:)
          end
        end

        def normalizer
          GisRobotSuite::RasterNormalizer.new(logger:, cocina_object:, rootdir:)
        end

        def rootdir
          @rootdir ||= GisRobotSuite.locate_druid_path bare_druid, type: :stage
        end
      end
    end
  end
end
