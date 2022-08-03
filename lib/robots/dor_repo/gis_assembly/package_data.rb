# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class PackageData < Base
        def initialize
          super('gisAssemblyWF', 'package-data', check_queued_status: true) # init LyberCore::Robot
        end

        # Create data.zip for all digital work files
        def generate_data_zip(druid, rootdir)
          tmpdir = File.join(rootdir, 'temp')
          LyberCore::Log.debug "Changing to #{tmpdir}"
          raise "package-data: #{druid} is missing #{tmpdir}" unless File.directory?(tmpdir)

          Dir.chdir(tmpdir)
          File.umask(002)

          fns = []
          recurse_flag = false
          fn = Dir.glob('*.shp.xml').first
          if fn.nil?
            fn = Dir.glob('*/metadata.xml').first
            if fn.nil?
              fn = Dir.glob('*.tif.xml').first
              raise "package-data: #{druid} cannot locate metadata in temp" if fn.nil?

              # GeoTIFF
              basename = File.basename(fn, '.tif.xml')
              Dir.glob("#{basename}.*").each do |x|
                fns << x
                recurse_flag = true if File.directory?(x)
              end
              Dir.glob("#{basename}-*.xml").each do |x|
                fns << x
              end
            else # ArcGRID
              fns << File.basename(File.dirname(fn))
              recurse_flag = true
            end
          else # Shapefile
            basename = File.basename(fn, '.shp.xml')
            Dir.glob("#{basename}.*").each do |x|
              fns << x
              recurse_flag = true if File.directory?(x)
            end
            Dir.glob("#{basename}-*.xml").each do |x|
              fns << x
            end
          end

          zipfn = File.join(rootdir, 'content', 'data.zip')
          FileUtils.mkdir_p(File.dirname(zipfn)) unless File.directory?(File.dirname(zipfn))
          FileUtils.rm_f(zipfn) if File.size?(zipfn)

          LyberCore::Log.debug "Compressing #{druid} into #{zipfn}"
          system "zip -v#{recurse_flag ? 'r' : ''} '#{zipfn}' #{fns.join(' ')}"
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid = druid.delete_prefix('druid:')
          LyberCore::Log.debug "package-data working on #{druid}"

          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage

          datafn = "#{rootdir}/content/data.zip"
          if File.size?(datafn)
            LyberCore::Log.info "package-data: #{druid} found existing packaged data: #{File.basename(datafn)}"
            return
          end

          generate_data_zip druid, rootdir
        end
      end
    end
  end
end
