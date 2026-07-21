# frozen_string_literal: true

require 'fileutils'
require 'shellwords'

module GisRobotSuite
  # Generates vector preview JP2 derivatives by first rasterizing the vector.
  class VectorPreviewGenerator
    def self.generate(input_path:, output_path:, logger: nil)
      new(input_path: input_path, output_path: output_path, logger: logger).generate
    end

    def initialize(input_path:, output_path:, logger: nil)
      @input_path = input_path
      @output_path = output_path
      @logger = logger
    end

    def generate
      basename = File.basename(output_path, '.jp2')
      temp_tif_path = output_path.parent / "#{basename}_temp.tif"
      temp_tif_aux_path = output_path.parent / "#{basename}_temp.tif.aux.xml"

      begin
        # Rasterize vector to a temporary TIFF file first
        rasterize_command = "gdal vector rasterize --size 512,512 --burn 255 --ot Byte #{Shellwords.escape(input_path.to_s)} #{Shellwords.escape(temp_tif_path.to_s)}"
        GisRobotSuite.run_system_command(rasterize_command, logger: logger)

        # Convert temporary TIFF to JP2
        Jp2Converter.convert(input_path: temp_tif_path, output_path: output_path, logger: logger)
      ensure
        # Make sure we clean up the temporary TIFF file and any associated auxiliary file
        FileUtils.rm_f(temp_tif_path)
        FileUtils.rm_f(temp_tif_aux_path)
      end
    end

    private

    attr_reader :input_path, :output_path, :logger
  end
end
