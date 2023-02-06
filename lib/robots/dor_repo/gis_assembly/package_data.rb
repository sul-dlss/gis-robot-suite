# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class PackageData < Base
        def initialize
          super('gisAssemblyWF', 'package-data')
        end

        def perform_work
          logger.debug "package-data working on #{bare_druid}"

          rootdir = GisRobotSuite.locate_druid_path(bare_druid, type: :stage)

          data_zip_filename = "#{rootdir}/content/data.zip"
          if File.size?(data_zip_filename)
            logger.info "package-data: #{bare_druid} found existing packaged data: #{File.basename(data_zip_filename)}"
            return
          end

          generate_data_zip(rootdir)
        end

        private

        # Create data.zip for all digital work files
        def generate_data_zip(rootdir)
          tmpdir = File.join(rootdir, 'temp')
          logger.debug "Changing to #{tmpdir}"
          raise "package-data: #{bare_druid} is missing #{tmpdir}" unless File.directory?(tmpdir)

          Dir.chdir(tmpdir)
          File.umask(002)

          fns = []
          recurse_flag = false
          fn = Dir.glob('*.shp.xml').first
          if fn.nil?
            fn = Dir.glob('*/metadata.xml').first
            if fn.nil?
              fn = Dir.glob('*.tif.xml').first
              raise "package-data: #{bare_druid} cannot locate metadata in temp" if fn.nil?

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

          logger.debug "Compressing #{bare_druid} into #{zipfn}"
          system("zip -v#{recurse_flag ? 'r' : ''} '#{zipfn}' #{fns.join(' ')}")
        end
      end
    end
  end
end
