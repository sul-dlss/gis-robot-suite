# frozen_string_literal: true

module GisRobotSuite
  class RasterNormalizer
    def initialize(logger:, cocina_object:, rootdir:)
      @logger = logger
      @cocina_object = cocina_object
      @rootdir = rootdir
    end

    def with_normalized
      yield normalize
    ensure
      cleanup
    end

    # @return [String] the path to the normalized raster
    def normalize
      raise "load-raster: #{bare_druid} cannot locate data type" unless data_format
      raise "load-raster: #{bare_druid} has unsupported Raster data type: #{data_format}" unless geotiff? || arcgrid?

      FileUtils.mkdir_p tmpdir

      epsg4326_projection? ? compress_only : reproject_and_compress
      convert_8bit_to_rgb if eight_bit?
      tmpdir
    end

    def cleanup
      logger.debug "Cleaning: #{tmpdir}"
      FileUtils.rm_rf tmpdir
    end

    private

    attr_reader :logger, :cocina_object, :rootdir

    def reproject_and_compress
      temp_filepath = "#{tmpdir}/#{geo_object_name}_uncompressed.tif"

      # reproject with gdalwarp (must uncompress here to prevent bloat)
      logger.info "load-raster: #{bare_druid} projecting #{geo_object_name} from #{projection_from_cocina_subject}"
      GisRobotSuite.run_system_command("#{Settings.gdal_path}gdalwarp -r bilinear -t_srs EPSG:4326 '#{input_filepath}' '#{temp_filepath}' -co 'COMPRESS=NONE'", logger:)
      raise "load-raster: #{bare_druid} gdalwarp failed to create #{temp_filepath}" unless File.size?(temp_filepath)

      compress(temp_filepath, output_filepath)
      FileUtils.rm_f(temp_filepath)
    end

    def compress_only
      compress(input_filepath, output_filepath)
    end

    def compress(input_filepath, output_filepath)
      logger.info "load-raster: #{bare_druid} is compressing to #{projection_from_cocina_subject}"
      GisRobotSuite.run_system_command("#{Settings.gdal_path}gdal_translate -a_srs EPSG:4326 '#{input_filepath}' '#{output_filepath}' -co 'COMPRESS=LZW'", logger:)
      raise "load-raster: #{bare_druid} gdal_translate failed to create #{output_filepath}" unless File.size?(output_filepath)
    end

    def eight_bit?
      cmd = "#{Settings.gdal_path}gdalinfo -json -norat -noct '#{output_filepath}'"
      gdalinfo_json_str = GisRobotSuite.run_system_command(cmd, logger:)[:stdout_str]
      gdalinfo_json = JSON.parse(gdalinfo_json_str)
      bands = gdalinfo_json['bands']
      # { "bands":[{ "band": 1, "block": [10503, 3], "type": "Byte", "colorInterpretation": "Palette" }] } # plus many other keys at each level
      return true if bands.any? { |band| band.key?('block') && band['type'] == 'Byte' && band['colorInterpretation'] == 'Palette' }

      false
    end

    def convert_8bit_to_rgb
      logger.info "load-raster: expanding color palette into rgb for #{output_filepath}"
      temp_filename = "#{tmpdir}/raw8bit.tif"
      GisRobotSuite.run_system_command("mv '#{output_filepath}' '#{temp_filename}'", logger:)
      GisRobotSuite.run_system_command("#{Settings.gdal_path}gdal_translate -expand rgb '#{temp_filename}' '#{output_filepath}' -co 'COMPRESS=LZW'", logger:)
      File.delete(temp_filename)
    end

    def tmpdir
      @tmpdir ||= File.join(Settings.geohydra.tmpdir, "normalizeraster_#{bare_druid}")
    end

    def data_format
      @data_format ||= GisRobotSuite.data_format(cocina_object)
    end

    def geotiff?
      data_format == 'GeoTIFF'
    end

    def arcgrid?
      data_format == 'ArcGRID'
    end

    def epsg4326_projection?
      projection_from_cocina_subject == 'EPSG:4326'
    end

    def projection_from_cocina_subject
      @projection_from_cocina_subject ||= cocina_object.description.geographic.first&.subject
                                                       &.find { |subject| subject.type == 'bounding box coordinates' }&.standard&.code&.upcase&.gsub('ESRI', 'EPSG')
    end

    def input_filepath
      @input_filepath ||= if arcgrid?
                            "#{content_dir}/#{geo_object_name}"
                          else # GeoTIFF
                            "#{content_dir}/#{geo_object_name}.tif"
                          end
    end

    def output_filepath
      @output_filepath ||= "#{tmpdir}/#{geo_object_name}.tif"
    end

    def geo_object_name
      @geo_object_name = if arcgrid?
                           filepath = Dir.glob("#{content_dir}/*/metadata.xml").first
                           filepath ? File.basename(File.dirname(filepath)) : nil
                         else # GeoTIFF
                           filepath = Dir.glob("#{content_dir}/*.tif.xml").first
                           filepath ? File.basename(filepath, '.tif.xml') : nil
                         end
    end

    def bare_druid
      @bare_druid ||= cocina_object.externalIdentifier.delete_prefix('druid:')
    end

    def content_dir
      @content_dir ||= "#{rootdir}/content"
    end
  end
end
