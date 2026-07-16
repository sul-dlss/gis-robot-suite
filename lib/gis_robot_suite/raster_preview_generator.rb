# frozen_string_literal: true

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
      Jp2Converter.convert(input_path: input_path, output_path: output_path, logger: logger)
    end

    private

    attr_reader :input_path, :output_path, :logger
  end
end
