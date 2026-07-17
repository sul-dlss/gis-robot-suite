# frozen_string_literal: true

module GisRobotSuite
  # Generates raster preview JP2 derivatives.
  class RasterPreviewGenerator
    # Data types the JP2 (OpenJPEG) driver is able to write directly.
    # Continuous raster data (e.g. Float32/Float64) is not supported and must
    # be scaled to one of these types before a JP2 can be created.
    JP2_COMPATIBLE_DATA_TYPES = %w[Byte Int16 UInt16 Int32 UInt32].freeze

    def self.generate(input_path:, output_path:, logger: nil)
      new(input_path: input_path, output_path: output_path, logger: logger).generate
    end

    def initialize(input_path:, output_path:, logger: nil)
      @input_path = input_path
      @output_path = output_path
      @logger = logger
    end

    def generate
      if jp2_compatible?
        convert_to_jp2(input_path)
      else
        scale_then_convert_to_jp2
      end
    end

    private

    attr_reader :input_path, :output_path, :logger

    # Continuous raster data (float types, etc.) can't be written to JP2 directly, so
    # first scale it into a temporary Int16 raster that the JP2 driver can handle.
    def scale_then_convert_to_jp2
      basename = File.basename(output_path, '.jp2')
      temp_tif_path = output_path.parent / "#{basename}_temp.tif"

      begin
        scale_command = "gdal raster scale --overwrite --ot Int16 #{Shellwords.escape(input_path.to_s)} #{Shellwords.escape(temp_tif_path.to_s)}"
        GisRobotSuite.run_system_command(scale_command, logger:)

        convert_to_jp2(temp_tif_path)
      ensure
        FileUtils.rm_f(temp_tif_path)
      end
    end

    def convert_to_jp2(input_path)
      Jp2Converter.convert(input_path:, output_path:, logger:)
    end

    def jp2_compatible?
      JP2_COMPATIBLE_DATA_TYPES.include?(data_type)
    end

    # The data type of the first band, e.g. "Byte", "Float32", as reported by gdalinfo.
    def data_type
      result = GisRobotSuite.run_system_command("gdalinfo -json #{Shellwords.escape(input_path.to_s)}", logger: logger)
      JSON.parse(result[:stdout_str])['bands'].first['type']
    end
  end
end
