# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'shellwords'

module GisRobotSuite
  # Generates vector preview JP2 derivatives by first rasterizing the vector.
  class VectorPreviewGenerator
    # gdal's stderr text when it can't derive a raster extent from the vector's
    # own bounding box: this happens for a layer with a single feature, or
    # several features that all sit at the same location, which has zero area.
    CANNOT_DETERMINE_BOUNDS_MESSAGE = 'Could not determine bounds'

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
        rasterize(temp_tif_path)

        # Convert temporary TIFF to JP2
        Jp2Converter.convert(input_path: temp_tif_path, output_path: output_path, logger: logger)
      ensure
        # Make sure we clean up the temporary TIFF file and any associated auxiliary file
        FileUtils.rm_f(temp_tif_path)
        FileUtils.rm_f(temp_tif_aux_path)
      end
    end

    private

    # Rasterize vector to a temporary TIFF file. Tries the vector's own extent
    # first; falls back to an explicit, padded extent if that fails
    def rasterize(temp_tif_path)
      GisRobotSuite.run_system_command(rasterize_command(temp_tif_path), logger: logger)
    rescue GisRobotSuite::SystemCommandNonzeroExit => e
      raise unless e.message.include?(CANNOT_DETERMINE_BOUNDS_MESSAGE)

      logger&.warn("Falling back to a padded extent for #{input_path}: gdal could not determine bounds (e.g. a single-point layer)")
      GisRobotSuite.run_system_command(rasterize_command(temp_tif_path, extent: padded_extent), logger: logger)
    end

    def rasterize_command(temp_tif_path, extent: nil)
      extent_option = extent ? "--extent #{extent.join(',')} " : ''
      "gdal vector rasterize --size 512,512 --burn 255 --ot Byte #{extent_option}" \
        "#{Shellwords.escape(input_path.to_s)} #{Shellwords.escape(temp_tif_path.to_s)}"
    end

    # Pads a zero-width and/or zero-height extent so gdal has a nonzero area to
    # compute a pixel size from. Generates padding proportional to the coordinate
    # system in use, so it works for any coordinate values.
    def padded_extent
      xmin, ymin, xmax, ymax = layer_extent
      pad = [xmax - xmin, ymax - ymin].max
      pad = [xmin.abs, ymin.abs, xmax.abs, ymax.abs, 1].max * 0.001 if pad.zero?
      [xmin - pad, ymin - pad, xmax + pad, ymax + pad]
    end

    def layer_extent
      info_command = "gdal vector info -f json #{Shellwords.escape(input_path.to_s)}"
      result = GisRobotSuite.run_system_command(info_command, logger: logger)
      JSON.parse(result[:stdout_str])['layers'].first['geometryFields'].first['extent']
    end

    attr_reader :input_path, :output_path, :logger
  end
end
