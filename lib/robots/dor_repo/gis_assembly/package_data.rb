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

          filenames = []
          recurse_flag = false
          filename = Dir.glob('*.shp.xml').first
          if filename.nil?
            filename = Dir.glob('*/metadata.xml').first
            if filename.nil?
              filename = Dir.glob('*.tif.xml').first
              raise "package-data: #{bare_druid} cannot locate metadata in temp" if filename.nil?

              # GeoTIFF
              basename = File.basename(filename, '.tif.xml')
              Dir.glob("#{basename}.*").each do |fname|
                filenames << fname
                recurse_flag = true if File.directory?(fname)
              end
              Dir.glob("#{basename}-*.xml").each do |xml_fname|
                filenames << xml_fname
              end
            else # ArcGRID
              filenames << File.basename(File.dirname(filename))
              recurse_flag = true
            end
          else # Shapefile
            basename = File.basename(filename, '.shp.xml')
            Dir.glob("#{basename}.*").each do |fname|
              filenames << fname
              recurse_flag = true if File.directory?(fname)
            end
            Dir.glob("#{basename}-*.xml").each do |xml_fname|
              filenames << xml_fname
            end
          end

          zip_filename = File.join(rootdir, 'content', 'data.zip')
          FileUtils.mkdir_p(File.dirname(zip_filename)) unless File.directory?(File.dirname(zip_filename))
          FileUtils.rm_f(zip_filename) if File.size?(zip_filename)

          logger.debug "Compressing #{bare_druid} into #{zip_filename}"
          system("zip -v#{recurse_flag ? 'r' : ''} '#{zip_filename}' #{filenames.join(' ')}")
        end
      end
    end
  end
end
