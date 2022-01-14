# frozen_string_literal: true

module Robots
  module DorRepo
    module GisDelivery
      class LoadRaster < Base
        def initialize
          super('gisDeliveryWF', 'load-raster', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid = druid.delete_prefix('druid:')
          LyberCore::Log.debug "load-raster working on #{druid}"

          rootdir = GisRobotSuite.locate_druid_path druid, type: :workspace

          # determine whether we have a Raster to load
          modsfn = File.join(rootdir, 'metadata', 'descMetadata.xml')
          raise "load-raster: #{druid} cannot locate MODS: #{modsfn}" unless File.size?(modsfn)

          format = GisRobotSuite.determine_file_format_from_mods modsfn
          raise "load-raster: #{druid} cannot determine file format from MODS: #{modsfn}" if format.nil?

          # perform based on file format information
          unless GisRobotSuite.raster?(format)
            LyberCore::Log.info "load-raster: #{druid} is not a raster, skipping"
            return
          end

          # extract derivative 4326 nomalized content
          projection = '4326' # always use EPSG:4326 derivative
          zipfn = File.join(rootdir, 'content', "data_EPSG_#{projection}.zip")
          raise "load-raster: #{druid} cannot locate normalized data: #{zipfn}" unless File.size?(zipfn)

          tmpdir = extract_data_from_zip druid, zipfn, Settings.geohydra.tmpdir
          raise "load-raster: #{druid} cannot locate #{tmpdir}" unless File.directory?(tmpdir)

          begin
            Dir.chdir(tmpdir)
            tiffn = Dir.glob('*.tif').first
            raise "load-raster: #{druid} cannot locate GeoTIFF: #{tmpdir}" if tiffn.nil?

            # copy to geoserver storage
            path = if Settings.geohydra.geotiff.host == 'localhost'
                     Settings.geohydra.geotiff.dir
                   else
                     [Settings.geohydra.geotiff.host, Settings.geohydra.geotiff.dir].join(':')
                   end
            cmd = "rsync -v '#{tiffn}' #{path}/#{druid}.tif"
            LyberCore::Log.debug "Running: #{cmd}"
            system(cmd)

            # copy statistics files
            cmd = "rsync -v '#{tiffn}'.aux.xml #{path}/#{druid}.tif.aux.xml"
            LyberCore::Log.debug "Running: #{cmd}"
            system(cmd)
          ensure
            LyberCore::Log.debug "Cleaning: #{tmpdir}"
            FileUtils.rm_rf tmpdir
          end
        end

        def extract_data_from_zip(druid, zipfn, tmpdir)
          LyberCore::Log.debug "load-raster: #{druid} extracting data: #{zipfn}"

          tmpdir = File.join(tmpdir, "loadraster_#{druid}")
          FileUtils.rm_rf tmpdir if File.directory? tmpdir
          FileUtils.mkdir_p tmpdir
          system("unzip '#{zipfn}' -d '#{tmpdir}'")
          tmpdir
        end
      end
    end
  end
end
