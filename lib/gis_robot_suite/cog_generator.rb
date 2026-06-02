# frozen_string_literal: true

module GisRobotSuite
  # Generates Cloud Optimized GeoTIFF (COG) derivatives.
  class CogGenerator
    def self.generate(input_path:, output_path:, logger: nil)
      new(input_path: input_path, output_path: output_path, logger: logger).generate
    end

    def initialize(input_path:, output_path:, logger: nil)
      @input_path = input_path
      @output_path = output_path
      @logger = logger
    end

    def generate
      command = "gdal raster convert --format=COG --co TILING_SCHEME=GoogleMapsCompatible #{Shellwords.escape(input_path.to_s)} #{Shellwords.escape(output_path.to_s)}"
      GisRobotSuite.run_system_command(command, logger: logger)
    end

    private

    attr_reader :input_path, :output_path, :logger
  end
end
