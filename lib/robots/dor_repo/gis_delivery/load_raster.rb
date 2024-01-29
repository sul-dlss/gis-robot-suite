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

          rootdir = GisRobotSuite.locate_druid_path bare_druid, type: :workspace

          # determine whether we have a Raster to load
          unless GisRobotSuite.raster?(cocina_object)
            logger.info "load-raster: #{bare_druid} is not a raster, skipping"
            return
          end

          # extract derivative 4326 nomalized content
          projection = '4326' # always use EPSG:4326 derivative
          data_zipe_filepath = GisRobotSuite.normalized_data_zip_filepath(rootdir, bare_druid)
          raise "load-raster: #{bare_druid} cannot locate normalized data: #{data_zipe_filepath}" unless File.size?(data_zipe_filepath)

          tmpdir = extract_data_from_zip data_zipe_filepath, Settings.geohydra.tmpdir
          raise "load-raster: #{bare_druid} cannot locate #{tmpdir}" unless File.directory?(tmpdir)

          begin
            Dir.chdir(tmpdir)
            tiffn = Dir.glob('*.tif').first
            raise "load-raster: #{bare_druid} cannot locate GeoTIFF: #{tmpdir}" if tiffn.nil?

            # copy to geoserver storage
            path = if Settings.geohydra.geotiff.host == 'localhost'
                     Settings.geohydra.geotiff.dir
                   else
                     [Settings.geohydra.geotiff.host, Settings.geohydra.geotiff.dir].join(':')
                   end
            cmd = "rsync -v '#{tiffn}' #{path}/#{bare_druid}.tif"
            logger.debug "Running: #{cmd}"
            system(cmd, exception: true)

            # copy statistics files
            cmd = "rsync -v '#{tiffn}'.aux.xml #{path}/#{bare_druid}.tif.aux.xml"
            logger.debug "Running: #{cmd}"
            system(cmd, exception: true)
          ensure
            logger.debug "Cleaning: #{tmpdir}"
            FileUtils.rm_rf tmpdir
          end
        end

        def extract_data_from_zip(data_zipe_filepath, tmpdir)
          logger.debug "load-raster: #{bare_druid} extracting data: #{data_zipe_filepath}"

          tmpdir = File.join(tmpdir, "loadraster_#{bare_druid}")
          FileUtils.rm_rf tmpdir if File.directory? tmpdir
          FileUtils.mkdir_p tmpdir
          system("unzip '#{data_zipe_filepath}' -d '#{tmpdir}'", exception: true)
          tmpdir
        end
      end
    end
  end
end
