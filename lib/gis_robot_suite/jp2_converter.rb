# frozen_string_literal: true

require 'shellwords'

module GisRobotSuite
  # Converts a GDAL-readable raster into a lossy JP2 derivative.
  module Jp2Converter
    # QUALITY=25 and REVERSIBLE=NO produce lossy, compact JP2 files.
    def self.convert(input_path:, output_path:, logger: nil)
      command = 'gdal convert --overwrite --co QUALITY=25 --co REVERSIBLE=NO ' \
                "#{Shellwords.escape(input_path.to_s)} #{Shellwords.escape(output_path.to_s)}"
      GisRobotSuite.run_system_command(command, logger: logger)
    end
  end
end
