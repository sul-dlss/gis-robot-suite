# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class NormalizeData < Base
        def initialize
          super('gisAssemblyWF', 'normalize-data')
        end

        def perform_work
          logger.debug "normalize-data working on #{bare_druid}"

          File.umask(002)

          normalizer_class = if GisRobotSuite.vector?(cocina_object)
                               ShapefileNormalizer
                             elsif GisRobotSuite.raster?(cocina_object)
                               RasterNormalizer
                             else
                               raise "normalize-data: #{bare_druid} has unsupported media type: #{GisRobotSuite.media_type(cocina_object)}"
                             end
          normalizer_class.new(robot: self).call
        end

        class BaseNormalizer
          def initialize(robot:)
            @robot = robot
          end

          def call
            logger.debug "Processing #{bare_druid} #{data_zip_filepath}"
            extract_to_tmpdir
            setup_output_dir

            begin
              raise "normalize-data: #{bare_druid} cannot locate geo object in #{tmpdir}" unless geo_object_name

              normalize
              cleanup_output_zip
              zip_output
              output_xml_metadata
            ensure
              cleanup_tmpdir
              cleanup_output_dir
            end
          end

          protected

          attr_reader :robot

          delegate :logger, :bare_druid, :cocina_object, to: :robot

          def system_with_check(cmd)
            logger.debug "normalize-data: running: #{cmd}"
            success = Kernel.system(cmd)
            raise "normalize-data: could not execute command successfully: #{success}: #{cmd}" unless success

            success
          end

          def tmpdir
            @tmpdir ||= File.join(Settings.geohydra.tmpdir, "normalize_#{bare_druid}")
          end

          def output_dir
            @output_dir ||= File.join(tmpdir, 'EPSG_4326')
          end

          def geo_object_name
            # For example, "sanluisobispo1996" given a data.zip containing "sanluisobispo1996.dbf".
            raise NotImplementedError
          end

          def normalize
            raise NotImplementedError
          end

          def zip_output
            raise NotImplementedError
          end

          def cleanup_tmpdir
            logger.debug "normalize-data: #{bare_druid} removing #{tmpdir}"
            FileUtils.rm_rf(tmpdir)
          end

          def cleanup_output_dir
            return unless File.directory?(output_dir)

            logger.debug "normalize-data: #{bare_druid} removing #{output_dir}"
            FileUtils.rm_rf(tmpdir)
          end

          def cleanup_output_zip
            FileUtils.rm_f(output_zip) if File.size?(output_zip)
          end

          def output_zip
            @output_zip ||= "#{rootdir}/content/data_EPSG_4326.zip"
          end

          def output_xml_metadata
            # Copy metadata files to the content directory
            iso19139_xml_file = Dir.glob("#{tmpdir}/*-iso19139.xml").first
            iso19110_xml_file = Dir.glob("#{tmpdir}/*-iso19110.xml").first
            fgdc_xml_file = Dir.glob("#{tmpdir}/*-fgdc.xml").first
            esri_xml_file = GisRobotSuite.locate_esri_metadata(tmpdir)

            [iso19139_xml_file, iso19110_xml_file, fgdc_xml_file, esri_xml_file].compact.map do |file|
              FileUtils.cp(file, "#{rootdir}/content/#{File.basename(file)}")
            end
          end

          private

          def rootdir
            @rootdir ||= GisRobotSuite.locate_druid_path bare_druid, type: :stage
          end

          def data_zip_filepath
            @data_zip_filepath ||= "#{rootdir}/content/data.zip"
          end

          def extract_to_tmpdir
            logger.debug "Extracting #{bare_druid} data from #{data_zip_filepath}"
            raise "normalize-data: #{bare_druid} cannot locate packaged data: #{data_zip_filepath}" unless File.size?(data_zip_filepath)

            FileUtils.rm_rf(tmpdir) if File.directory?(tmpdir)
            FileUtils.mkdir_p(tmpdir)
            system_with_check("unzip -o '#{data_zip_filepath}' -d '#{tmpdir}'")
          end

          def setup_output_dir
            FileUtils.rm_rf(output_dir) if File.directory?(output_dir)
            FileUtils.mkdir_p(output_dir)
          end
        end

        class ShapefileNormalizer < BaseNormalizer
          def normalize
            reproject
            normalize_prj_file
          end

          def zip_output
            system_with_check("zip -Dj '#{output_zip}' \"#{output_dir}/#{geo_object_name}\".*")
          end

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
            @vector_filepath ||= Dir.glob("#{tmpdir}/*#{vector_file_extention}").first
          end

          def wkt
            # Well Known Text. It’s a text markup language for expressing geometries in vector data.
            @wkt ||= URI.open('https://spatialreference.org/ref/epsg/4326/prettywkt/').read
          end

          def reproject
            # See http://www.gdal.org/ogr2ogr.html
            output_filepath = File.join(output_dir, "#{geo_object_name}.shp") # output shapefile
            logger.info "normalize-data: #{bare_druid} is projecting #{geo_object_name} to EPSG:4326"
            system_with_check("env SHAPE_ENCODING= #{Settings.gdal_path}ogr2ogr -progress -t_srs '#{wkt}' '#{output_filepath}' '#{vector_filepath}'") # prevent recoding
            raise "normalize-data: #{bare_druid} failed to reproject #{vector_filepath}" unless File.size?(output_filepath)
          end

          def normalize_prj_file
            output_filepath = File.join(output_dir, "#{geo_object_name}.prj")
            logger.debug "normalize-data: #{bare_druid} overwriting #{output_filepath}"
            File.write(output_filepath, wkt)
          end
        end

        class RasterNormalizer < BaseNormalizer
          def normalize
            raise "normalize-data: #{bare_druid} cannot locate data type" unless data_format
            raise "normalize-data: #{bare_druid} has unsupported Raster data type: #{data_format}" unless geotiff? || arcgrid?

            if epsg4326_projection?
              compress_only
            else
              reproject_and_compress
            end

            # if using 8-bit color palette, convert into RGB
            convert_8bit_to_rgb if eight_bit?

            add_alpha_channel

            compute_statistics
          end

          def geo_object_name
            @geo_object_name = if arcgrid?
                                 filepath = Dir.glob("#{tmpdir}/*/metadata.xml").first
                                 filepath ? File.basename(File.dirname(filepath)) : nil
                               else # GeoTIFF
                                 filepath = Dir.glob("#{tmpdir}/*.tif.xml").first
                                 filepath ? File.basename(filepath, '.tif.xml') : nil
                               end
          end

          def zip_output
            system_with_check("zip -Dj '#{output_zip}' '#{output_filepath}'*")
          end

          private

          def data_format
            @data_format ||= GisRobotSuite.data_format(cocina_object)
          end

          def geotiff?
            data_format == 'GeoTIFF'
          end

          def arcgrid?
            data_format == 'ArcGRID'
          end

          def reproject_and_compress
            temp_filepath = "#{output_dir}/#{geo_object_name}_uncompressed.tif"

            # reproject with gdalwarp (must uncompress here to prevent bloat)
            logger.info "normalize-data: #{bare_druid} projecting #{geo_object_name} from #{projection_from_cocina_subject}"
            system_with_check "#{Settings.gdal_path}gdalwarp -r bilinear -t_srs EPSG:4326 #{input_filepath} #{temp_filepath} -co 'COMPRESS=NONE'"
            raise "normalize-data: #{bare_druid} gdalwarp failed to create #{temp_filepath}" unless File.size?(temp_filepath)

            compress(temp_filepath, output_filepath)
            FileUtils.rm_f(temp_filepath)
          end

          def compress_only
            compress(input_filepath, output_filepath)
          end

          def epsg4326_projection?
            projection_from_cocina_subject == 'EPSG:4326'
          end

          def projection_from_cocina_subject
            @projection_from_cocina_subject ||= cocina_object.description.geographic.first&.subject
                                                             &.find { |subject| subject.type == 'bounding box coordinates' }&.standard&.code&.upcase&.gsub('ESRI', 'EPSG')
          end

          def compress(input_filepath, output_filepath)
            logger.info "normalize-data: #{bare_druid} is compressing to #{projection_from_cocina_subject}"
            system_with_check("#{Settings.gdal_path}gdal_translate -a_srs EPSG:4326 #{input_filepath} #{output_filepath} -co 'COMPRESS=LZW'")
            raise "normalize-data: #{bare_druid} gdal_translate failed to create #{output_filepath}" unless File.size?(output_filepath)
          end

          def input_filepath
            @input_filepath ||= if arcgrid?
                                  "#{tmpdir}/#{geo_object_name}"
                                else # GeoTIFF
                                  "#{tmpdir}/#{geo_object_name}.tif"
                                end
          end

          def output_filepath
            @output_filepath ||= "#{output_dir}/#{geo_object_name}.tif"
          end

          def convert_8bit_to_rgb
            logger.info "normalize-data: expanding color palette into rgb for #{output_filepath}"
            temp_filename = "#{tmpdir}/raw8bit.tif"
            system_with_check("mv #{output_filepath} #{temp_filename}")
            system_with_check("#{Settings.gdal_path}gdal_translate -expand rgb #{temp_filename} #{output_filepath} -co 'COMPRESS=LZW'")
          end

          def eight_bit?
            cmd = "#{Settings.gdal_path}gdalinfo -json -norat -noct '#{output_filepath}'"
            IO.popen(cmd).read.tap do |gdalinfo_json_str|
              gdalinfo_json = JSON.parse(gdalinfo_json_str)
              bands = gdalinfo_json['bands']
              # { "bands":[{ "band": 1, "block": [10503, 3], "type": "Byte", "colorInterpretation": "Palette" }] } # plus many other keys at each level
              return true if bands.any? { |band| band.key?('block') && band['type'] == 'Byte' && band['colorInterpretation'] == 'Palette' }
            end
            false
          end

          def add_alpha_channel
            # NOTE: gdalwarp is smart enough not to add a new alpha channel (band) if one is already there.
            # If we want to improve the performance of the normalize step, and many GeoTIFFs already
            # have alpha channels, then we could introspect on the GeoTIFF file with gdalinfo and skip
            # this call to gdalwarp if one is already present.
            logger.info "normalize-data: adding alpha channel for #{output_filepath}"
            temp_filepath = "#{output_dir}/#{geo_object_name}_alpha.tif"
            system_with_check("#{Settings.gdal_path}gdalwarp -dstalpha #{output_filepath} #{temp_filepath}")
            FileUtils.mv(temp_filepath, output_filepath)
          end

          def compute_statistics
            # NOTE: other invocations of gdalinfo parse JSON output.  This produces an .aux.xml output file that
            # is consumed (we think?) by the LoadRaster robot (which at the very least, rsyncs it to another location,
            # as of Feb 2024).
            system_with_check("#{Settings.gdal_path}gdalinfo -mm -stats -norat -noct #{output_filepath}")
          end
        end
      end
    end
  end
end
