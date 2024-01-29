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
          data_zip_filepath = GisRobotSuite.data_zip_filepath(rootdir, bare_druid)

          if File.size?(data_zip_filepath)
            logger.info "package-data: #{bare_druid} found existing packaged data: #{File.basename(data_zip_filepath)}"
            return
          end

          generate_data_zip(rootdir, data_zip_filepath)
        end

        private

        # Create zip for all digital work files
        def generate_data_zip(rootdir, data_zip_filepath)
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

          FileUtils.mkdir_p(File.dirname(data_zip_filepath)) unless File.directory?(File.dirname(data_zip_filepath))
          FileUtils.rm_f(data_zip_filepath) if File.size?(data_zip_filepath)

          logger.debug "Compressing #{bare_druid} into #{data_zip_filepath}"
          system("zip -v#{recurse_flag ? 'r' : ''} '#{data_zip_filepath}' #{fns.join(' ')}")
        end
      end
    end
  end
end
