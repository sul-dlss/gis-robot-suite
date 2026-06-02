# frozen_string_literal: true

require 'fileutils'

module GisRobotSuite
  # Generates vector derivatives (FlatGeoBuf and PMTiles).
  class VectorDerivativeGenerator
    def self.generate(input_path:, fgb_path:, pmtiles_path:, logger: nil)
      new(input_path: input_path, fgb_path: fgb_path, pmtiles_path: pmtiles_path, logger: logger).generate
    end

    def initialize(input_path:, fgb_path:, pmtiles_path:, logger: nil)
      @input_path = input_path
      @fgb_path = fgb_path
      @pmtiles_path = pmtiles_path
      @logger = logger
    end

    def generate
      basename = File.basename(fgb_path, '.fgb')
      temp_fgb_output = fgb_path.parent / "#{basename}_temp.fgb"

      # Generate FlatGeoBuf
      fgb_command = "gdal vector convert --output-format 'FlatGeoBuf' #{Shellwords.escape(input_path.to_s)} #{Shellwords.escape(temp_fgb_output.to_s)}"
      GisRobotSuite.run_system_command(fgb_command, logger: logger)

      # Convert the FlatGeoBuf to EPSG:4326
      reproject_command = "gdal vector reproject --dst-crs=EPSG:4326 #{Shellwords.escape(temp_fgb_output.to_s)} #{Shellwords.escape(fgb_path.to_s)}"
      GisRobotSuite.run_system_command(reproject_command, logger: logger)

      FileUtils.rm_f(temp_fgb_output)

      # Generate PMTiles from FlatGeoBuf
      pmtiles_command = "tippecanoe -o #{Shellwords.escape(pmtiles_path.to_s)} -zg #{Shellwords.escape(fgb_path.to_s)} --drop-densest-as-needed --extend-zooms-if-still-dropping"
      GisRobotSuite.run_system_command(pmtiles_command, logger: logger)
    end

    private

    attr_reader :input_path, :fgb_path, :pmtiles_path, :logger
  end
end
