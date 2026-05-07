# frozen_string_literal: true

module GisRobotSuite
  class VectorNormalizer
    def initialize(logger:, bare_druid:, rootdir:)
      @logger = logger
      @bare_druid = bare_druid
      @rootdir = rootdir
    end

    def with_normalized
      yield normalize
    ensure
      cleanup
    end

    # @return [String] the path to the normalized vector
    def normalize
      FileUtils.mkdir_p tmpdir

      normalize_shp

      tmpdir
    end

    def cleanup
      logger.debug "Cleaning: #{tmpdir}"
      FileUtils.rm_rf tmpdir
    end

    private

    attr_reader :logger, :bare_druid, :rootdir

    def tmpdir
      @tmpdir ||= File.join(Settings.geohydra.tmpdir, "normalizevector_#{bare_druid}")
    end

    def vector_filepath
      @vector_filepath ||= Dir.glob("#{rootdir}/content/*.{shp,geojson}").first
    end

    def geo_object_name
      @geo_object_name ||= File.basename(vector_filepath, File.extname(vector_filepath))
    end

    def normalize_shp
      # See https://gdal.org/programs/gdal_vector_reproject.html
      output_filepath = File.join(tmpdir, "#{geo_object_name}.shp")
      logger.info "normalize-vector: #{bare_druid} is projecting #{geo_object_name} to EPSG:4326"

      # gdal vector reproject automatically creates the .prj file alongside the shapefile
      GisRobotSuite.run_system_command(
        "env SHAPE_ENCODING= #{Settings.gdal_path}gdal vector reproject --dst-crs=EPSG:4326 --overwrite '#{vector_filepath}' '#{output_filepath}'",
        logger:
      )
      raise "normalize-vector: #{bare_druid} failed to reproject #{vector_filepath}" unless File.size?(output_filepath)
    end
  end
end
