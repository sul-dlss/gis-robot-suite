# frozen_string_literal: true

module GisRobotSuite
  # Generates Cloud Optimized GeoTIFF (COG) derivatives.
  class CogGenerator
    # Unsigned-integer data types (TIFF SampleFormat=1) that the deck.gl COG
    # viewer can render directly. Signed-integer and floating-point rasters
    # (SampleFormat 2 and 3) are not supported and must first be scaled into an
    # unsigned type. See https://github.com/sul-dlss/gis-robot-suite/issues/1200
    #
    # NOTE: deck.gl-geotiff has an unmerged PR for support for signed integer
    # rasters; see: https://github.com/developmentseed/deck.gl-raster/pull/180
    UNSIGNED_DATA_TYPES = %w[Byte UInt16 UInt32 UInt64].freeze

    def self.generate(input_path:, output_path:, logger: nil)
      new(input_path: input_path, output_path: output_path, logger: logger).generate
    end

    def initialize(input_path:, output_path:, logger: nil)
      @input_path = input_path
      @output_path = output_path
      @logger = logger
    end

    def generate
      if unsigned?
        convert_to_cog(input_path)
      else
        scale_then_convert_to_cog
      end
    end

    private

    attr_reader :input_path, :output_path, :logger

    # Signed-integer and floating-point rasters can't be rendered by the deck.gl
    # COG viewer, so first scale the data into an unsigned Byte raster. The data
    # range is mapped to [1, 255] and NoData is remapped to 0, keeping it out of
    # the data range so the viewer can filter it out.
    def scale_then_convert_to_cog
      basename = File.basename(output_path.to_s, '.tif')
      temp_tif_path = output_path.parent / "#{basename}_scaled.tif"

      logger&.warn("Scaling #{data_type} to unsigned Byte for COG generation; data loss may occur!")

      begin
        min, max = data_min_max
        scale_command = "gdal_translate -scale #{min} #{max} 1 255 -ot Byte -a_nodata 0 " \
                        "#{Shellwords.escape(input_path.to_s)} #{Shellwords.escape(temp_tif_path.to_s)}"
        GisRobotSuite.run_system_command(scale_command, logger:)

        convert_to_cog(temp_tif_path)
      ensure
        FileUtils.rm_f(temp_tif_path)
      end
    end

    def convert_to_cog(input_path)
      command = "gdal raster convert --overwrite --format=COG --co TILING_SCHEME=GoogleMapsCompatible #{Shellwords.escape(input_path.to_s)} #{Shellwords.escape(output_path.to_s)}"
      GisRobotSuite.run_system_command(command, logger: logger)
    end

    def unsigned?
      UNSIGNED_DATA_TYPES.include?(data_type)
    end

    # The data type of the first band, e.g. "Byte", "Float64", as reported by gdalinfo.
    def data_type
      result = GisRobotSuite.run_system_command("gdalinfo -json #{Shellwords.escape(input_path.to_s)}", logger: logger)
      JSON.parse(result[:stdout_str])['bands'].first['type']
    end

    # The first band's computed minimum and maximum values, excluding NoData.
    def data_min_max
      result = GisRobotSuite.run_system_command("gdalinfo -json -mm #{Shellwords.escape(input_path.to_s)}", logger: logger)
      band = JSON.parse(result[:stdout_str])['bands'].first
      [band['computedMin'], band['computedMax']]
    end
  end
end
