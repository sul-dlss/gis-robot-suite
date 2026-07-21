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
      temp_fgb_output = fgb_path.parent / "#{basename}_before.fgb"

      # Generate FlatGeoBuf, promoting geometry to multi
      # See issue: https://github.com/OSGeo/gdal/issues/2828
      # And fix: https://github.com/OSGeo/gdal/pull/14662
      # Note: this behavior will be automatic in GDAL 3.14 (as yet unreleased);
      # when it is released we can install it switch back to the `gdal convert` API.
      fgb_command = "ogr2ogr -of 'FlatGeoBuf' -lco OVERWRITE=yes -nlt PROMOTE_TO_MULTI #{Shellwords.escape(temp_fgb_output.to_s)} #{Shellwords.escape(input_path.to_s)} #{basename}"
      GisRobotSuite.run_system_command(fgb_command, logger: logger)

      # Convert the FlatGeoBuf to EPSG:4326
      reproject_command = "gdal vector reproject --dst-crs=EPSG:4326 --overwrite #{Shellwords.escape(temp_fgb_output.to_s)} #{Shellwords.escape(fgb_path.to_s)}"
      GisRobotSuite.run_system_command(reproject_command, logger: logger)

      FileUtils.rm_f(temp_fgb_output)

      # Generate PMTiles from FlatGeoBuf
      pmtiles_command = "tippecanoe -o #{Shellwords.escape(pmtiles_path.to_s)} -zg #{Shellwords.escape(fgb_path.to_s)} " \
                        '--drop-densest-as-needed --extend-zooms-if-still-dropping --force'
      GisRobotSuite.run_system_command(pmtiles_command, logger: logger)
    end

    private

    attr_reader :input_path, :fgb_path, :pmtiles_path, :logger
  end
end
