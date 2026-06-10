# frozen_string_literal: true

require 'shellwords'

module GisRobotSuite
  # Generates raster preview JP2 derivatives.
  class RasterPreviewGenerator
    def self.generate(input_path:, output_path:, logger: nil)
      new(input_path: input_path, output_path: output_path, logger: logger).generate
    end

    def initialize(input_path:, output_path:, logger: nil)
      @input_path = input_path
      @output_path = output_path
      @logger = logger
    end

    def generate
      command = "gdal convert #{Shellwords.escape(input_path.to_s)} #{Shellwords.escape(output_path.to_s)}"
      GisRobotSuite.run_system_command(command, logger: logger)
    end

    private

    attr_reader :input_path, :output_path, :logger
  end
end
