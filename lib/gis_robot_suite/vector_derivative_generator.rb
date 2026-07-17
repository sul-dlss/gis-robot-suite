# frozen_string_literal: true

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
      # Generate FlatGeoBuf in a single pass: drop unusable geometry, promote
      # mixed geometry to multi, and reproject to EPSG:4326.
      fgb_command = "ogr2ogr -of 'FlatGeoBuf' #{overwrite_output} #{reproject_to_wgs84} " \
                    "#{promote_to_multi} #{select_valid_geometry} " \
                    "#{Shellwords.escape(fgb_path.to_s)} #{Shellwords.escape(input_path.to_s)}"
      GisRobotSuite.run_system_command(fgb_command, logger: logger)

      # Generate PMTiles from FlatGeoBuf
      pmtiles_command = "tippecanoe -o #{Shellwords.escape(pmtiles_path.to_s)} -zg #{Shellwords.escape(fgb_path.to_s)} " \
                        '--drop-densest-as-needed --extend-zooms-if-still-dropping --force'
      GisRobotSuite.run_system_command(pmtiles_command, logger: logger)
    end

    private

    # Filename minus extension is assumed to be layer name in the data, also
    # used as basename for all files
    def layer_name
      File.basename(input_path, '.*')
    end

    # PMTiles can only be created from data in EPSG:4326, so we reproject
    # the input FlatGeoBuf to that projection.
    def reproject_to_wgs84
      '-t_srs EPSG:4326'
    end

    # The -overwrite output switch doesn't work for FlatGeoBuf because it
    # doesn't support DeleteLayer(), but this does.
    def overwrite_output
      '-lco OVERWRITE=yes'
    end

    # Selects only geometry that can be indexed by FlatGeoBuf and reprojected:
    #   - Null geometry isn't supported by FlatGeoBuf's spatial index.
    #   - Some Shapefiles use DBL_MAX to indicate "nodata". Such geometry falls
    #     outside any real projection bounds, so reprojecting it yields null
    #     geometry, which FlatGeoBuf then rejects and which aborts the whole
    #     write (leaving a FlatGeoBuf with zero features).
    # The bounds are checked against the geometry envelope (ST_MinX/MaxX/MinY/
    # MaxY) rather than ST_X/ST_Y so the check works for all geometry types, not
    # just points. 1e9 keeps every real-world coordinate (degrees, meters, feet)
    # while excluding the DBL_MAX sentinel.
    def select_valid_geometry
      sql = "select * from #{layer_name} where geometry is not null " \
            'and ST_MinX(geometry) between -1e9 and 1e9 and ST_MaxX(geometry) between -1e9 and 1e9 ' \
            'and ST_MinY(geometry) between -1e9 and 1e9 and ST_MaxY(geometry) between -1e9 and 1e9'
      "-dialect sqlite -sql '#{sql}'"
    end

    # Promote mixed geometry to multi
    # See issue: https://github.com/OSGeo/gdal/issues/2828
    # And fix: https://github.com/OSGeo/gdal/pull/14662
    # Note: this behavior will be automatic in GDAL 3.14 (as yet unreleased);
    # when it is released we can install it switch back to the `gdal convert` API.
    def promote_to_multi
      '-nlt PROMOTE_TO_MULTI'
    end

    attr_reader :input_path, :fgb_path, :pmtiles_path, :logger
  end
end
