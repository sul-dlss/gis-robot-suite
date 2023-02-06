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
          modsfn = File.join(rootdir, 'metadata', 'descMetadata.xml')
          raise "load-raster: #{bare_druid} cannot locate MODS: #{modsfn}" unless File.size?(modsfn)

          format = GisRobotSuite.determine_file_format_from_mods modsfn
          raise "load-raster: #{bare_druid} cannot determine file format from MODS: #{modsfn}" if format.nil?

          # perform based on file format information
          unless GisRobotSuite.raster?(format)
            logger.info "load-raster: #{bare_druid} is not a raster, skipping"
            return
          end

          # extract derivative 4326 nomalized content
          projection = '4326' # always use EPSG:4326 derivative
          zipfn = File.join(rootdir, 'content', "data_EPSG_#{projection}.zip")
          raise "load-raster: #{bare_druid} cannot locate normalized data: #{zipfn}" unless File.size?(zipfn)

          tmpdir = extract_data_from_zip zipfn, Settings.geohydra.tmpdir
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

        def extract_data_from_zip(zipfn, tmpdir)
          logger.debug "load-raster: #{bare_druid} extracting data: #{zipfn}"

          tmpdir = File.join(tmpdir, "loadraster_#{bare_druid}")
          FileUtils.rm_rf tmpdir if File.directory? tmpdir
          FileUtils.mkdir_p tmpdir
          system("unzip '#{zipfn}' -d '#{tmpdir}'", exception: true)
          tmpdir
        end
      end
    end
  end
end
