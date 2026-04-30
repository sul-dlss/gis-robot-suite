# frozen_string_literal: true

require 'open3'

module GisRobotSuite
  class CogValidator
    def self.valid?(filename)
      stdout, stderr, status = Open3.capture3(
        'uv', 'run', 'lib/gis_robot_suite/validate_cloud_optimized_geotiff.py', filename
      )

      raise "uv script failed for #{filename}: #{stderr.strip}" if !status.success? && !stdout.include?('cloud optimized GeoTIFF')

      stdout.include?('is a valid cloud optimized GeoTIFF')
    end
  end
end
