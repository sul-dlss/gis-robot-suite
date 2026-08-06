# frozen_string_literal: true

module GisRobotSuite
  # Generates vector derivatives (FlatGeoBuf and PMTiles).
  class VectorDerivativeGenerator
    # tippecanoe's stderr text when -zg has too little data to guess a maxzoom from
    # (e.g. a single-feature layer, or several features at the same coordinates).
    # tippecanoe exits 110 (EXIT_NODATA) for this *and* other unrelated "no data"
    # conditions, so we match on this exact message rather than the exit code
    CANNOT_GUESS_MAXZOOM_MESSAGE = "Can't guess maxzoom (-zg) without at least two distinct feature locations"

    # tippecanoe's own documented default maxzoom (see `tippecanoe --help`), used
    # as a fallback when there isn't enough spatial spread for -zg to guess one
    FALLBACK_MAXZOOM = 14

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

      generate_pmtiles
    end

    private

    # Generate PMTiles from FlatGeoBuf. Tries to auto-guess an appropriate maxzoom
    # first; falls back to a fixed maxzoom if that fails
    def generate_pmtiles
      GisRobotSuite.run_system_command(pmtiles_command(zoom_flag: '-zg'), logger: logger)
    rescue GisRobotSuite::SystemCommandNonzeroExit => e
      raise unless e.message.include?(CANNOT_GUESS_MAXZOOM_MESSAGE)

      logger&.warn("Falling back to maxzoom=#{FALLBACK_MAXZOOM} for #{fgb_path}: tippecanoe could not guess a maxzoom (-zg)")
      GisRobotSuite.run_system_command(pmtiles_command(zoom_flag: "-z#{FALLBACK_MAXZOOM}"), logger: logger)
    end

    def pmtiles_command(zoom_flag:)
      "tippecanoe -o #{Shellwords.escape(pmtiles_path.to_s)} #{zoom_flag} #{Shellwords.escape(fgb_path.to_s)} " \
        '--drop-densest-as-needed --extend-zooms-if-still-dropping --force'
    end

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
