# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class CopyData < Base
        def initialize
          super('gisAssemblyWF', 'copy-data')
        end

        def perform_work
          logger.debug "copy-data working on #{bare_druid}"

          File.umask(002)

          copier_class = if GisRobotSuite.vector?(cocina_object)
                           ShapefileCopier
                         elsif GisRobotSuite.raster?(cocina_object)
                           RasterCopier
                         else
                           raise "copy-data: #{bare_druid} has unsupported media type: #{GisRobotSuite.media_type(cocina_object)}"
                         end
          copier_class.new(robot: self).call
        end

        class BaseCopier
          def initialize(robot:)
            @robot = robot
          end

          def call
            logger.debug "Processing #{bare_druid}"

            raise "copy-data: #{bare_druid} cannot locate geo object in #{temp_dir}" unless geo_object_name

            FileUtils.mkdir_p(content_dir)
            copy_metadata # Copy metadata files to the content directory
            copy_data # Copy data files to the content directory
            copy_thumbnail # Copy thumbnail to the content directory
          end

          protected

          attr_reader :robot

          delegate :logger, :bare_druid, :cocina_object, to: :robot

          def temp_dir
            @temp_dir ||= File.join(rootdir, 'temp')
          end

          def geo_object_name
            # For example, "sanluisobispo1996" given a data.zip containing "sanluisobispo1996.dbf".
            raise NotImplementedError
          end

          def content_dir
            @content_dir ||= "#{rootdir}/content"
          end

          def output_zip
            @output_zip ||= "#{content_dir}/data_EPSG_4326.zip"
          end

          def copy_metadata
            copy_files_to_content([GisRobotSuite.locate_esri_metadata(temp_dir)] + GisRobotSuite.locate_derivative_metadata_files(temp_dir))
          end

          def copy_data
            copy_files_to_content(GisRobotSuite.locate_data_files(temp_dir))
          end

          def copy_thumbnail
            thumbnail_file = File.join(rootdir, 'content', 'preview.jpg')
            return thumbnail_file if File.size?(thumbnail_file)

            temp_thumbnail_file = File.join(rootdir, 'temp', 'preview.jpg')
            raise "copy-data: #{bare_druid} is missing thumbnail preview.jpg" unless File.size?(temp_thumbnail_file)

            FileUtils.cp(temp_thumbnail_file, thumbnail_file)
          end

          private

          def copy_files_to_content(files)
            files.compact.map do |file|
              FileUtils.cp(file, "#{rootdir}/content/#{File.basename(file)}")
            end
          end

          def rootdir
            @rootdir ||= GisRobotSuite.locate_druid_path bare_druid, type: :stage
          end
        end

        class ShapefileCopier < BaseCopier
          def geo_object_name
            @geo_object_name ||= vector_filepath ? File.basename(vector_filepath, vector_file_extention) : nil
          end

          private

          def data_format
            @data_format ||= GisRobotSuite.data_format(cocina_object)
          end

          def geojson?
            data_format == 'GeoJSON'
          end

          def vector_file_extention
            @vector_file_extention ||= geojson? ? '.geojson' : '.shp'
          end

          def vector_filepath
            @vector_filepath ||= Dir.glob("#{temp_dir}/*#{vector_file_extention}").first
          end
        end

        class RasterCopier < BaseCopier
          def geo_object_name
            @geo_object_name = if arcgrid?
                                 filepath = Dir.glob("#{temp_dir}/*/metadata.xml").first
                                 filepath ? File.basename(File.dirname(filepath)) : nil
                               else # GeoTIFF
                                 filepath = Dir.glob("#{temp_dir}/*.tif.xml").first
                                 filepath ? File.basename(filepath, '.tif.xml') : nil
                               end
          end

          private

          def data_format
            @data_format ||= GisRobotSuite.data_format(cocina_object)
          end

          def arcgrid?
            data_format == 'ArcGRID'
          end
        end
      end
    end
  end
end
