# frozen_string_literal: true

module GisRobotSuite
  class VectorNormalizer
    TARGET_CRS = 'EPSG:4326'

    def initialize(logger:, cocina_object:, rootdir:)
      @logger = logger
      @cocina_object = cocina_object
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

      target_projection? ? link_source : reproject_shp

      tmpdir
    end

    def cleanup
      logger.debug "Cleaning: #{tmpdir}"
      FileUtils.rm_rf tmpdir
    end

    private

    attr_reader :logger, :cocina_object, :rootdir

    def bare_druid
      @bare_druid ||= cocina_object.externalIdentifier.delete_prefix('druid:')
    end

    def tmpdir
      @tmpdir ||= File.join(Settings.geohydra.tmpdir, "normalizevector_#{bare_druid}")
    end

    def vector_filepath
      @vector_filepath ||= Dir.glob("#{rootdir}/content/*.{shp,geojson}").first
    end

    def geo_object_name
      @geo_object_name ||= File.basename(vector_filepath, File.extname(vector_filepath))
    end

    def output_filepath
      @output_filepath ||= File.join(tmpdir, "#{geo_object_name}.shp")
    end

    def reproject_shp
      # See https://gdal.org/programs/gdal_vector_reproject.html
      logger.info "normalize-vector: #{bare_druid} is projecting #{geo_object_name} to #{TARGET_CRS}"

      # gdal vector reproject automatically creates the .prj file alongside the shapefile
      GisRobotSuite.run_system_command(
        "env SHAPE_ENCODING= #{Settings.gdal_path}gdal vector reproject #{src_crs_option}--dst-crs=#{TARGET_CRS} " \
        "--overwrite '#{vector_filepath}' '#{output_filepath}'",
        logger:
      )
      raise "normalize-vector: #{bare_druid} failed to reproject #{vector_filepath}" unless File.size?(output_filepath)
    end

    # Reprojecting data that is already in the target projection would rewrite the whole dataset
    # to produce a copy of it, so link it into the tmpdir instead. Beyond being wasteful, the
    # rewrite is not always possible: a shapefile whose .dbf has been truncated at the 2GB limit
    # can still be read, but cannot be written back out.
    def link_source
      logger.info "normalize-vector: #{bare_druid} is already in #{TARGET_CRS}, linking #{geo_object_name}"

      # Link every sibling, not just the .shp, so that the layer stays openable: the shapefile
      # driver needs the .shx and .dbf, and the .cpg and .prj inform how it reads them.
      Dir.glob("#{rootdir}/content/#{geo_object_name}.*").each do |filepath|
        FileUtils.ln_s(File.expand_path(filepath), File.join(tmpdir, File.basename(filepath)))
      end
      linked_filepath = File.join(tmpdir, File.basename(vector_filepath))
      raise "normalize-vector: #{bare_druid} failed to link #{vector_filepath}" unless File.size?(linked_filepath)
    end

    def src_crs_option
      # GDAL uses the CRS the file declares, so only name one when the file declares none.
      return '' if declared_coordinate_system

      "--src-crs=#{fallback_crs} "
    end

    def target_projection?
      (declared_coordinate_system ? declared_crs : fallback_crs) == TARGET_CRS
    end

    # The coordinate system the data file itself declares, which for a shapefile means its .prj.
    # Legacy ESRI datasets were frequently accessioned without one.
    def declared_coordinate_system
      return @declared_coordinate_system if defined?(@declared_coordinate_system)

      @declared_coordinate_system = vector_info.dig('layers', 0, 'geometryFields', 0, 'coordinateSystem')
    end

    # @return [String, nil] e.g. "EPSG:26910"; nil when the declared CRS carries no authority code
    def declared_crs
      id = declared_coordinate_system.dig('projjson', 'id')

      "#{id['authority']}:#{id['code']}" if id
    end

    # The projection recorded in the descriptive metadata, used when the data file declares none.
    # generate-descriptive runs earlier in gisAssemblyWF and raises when it cannot determine one,
    # so this is only missing for a projection GDAL has no code for.
    def fallback_crs
      GisRobotSuite.map_projection(cocina_object) ||
        raise("normalize-vector: #{bare_druid} #{geo_object_name} has no spatial reference system " \
              'and cocina records no map projection to fall back on')
    end

    def vector_info
      @vector_info ||= JSON.parse(
        GisRobotSuite.run_system_command("#{Settings.gdal_path}gdal vector info -f json '#{vector_filepath}'", logger:)[:stdout_str]
      )
    end
  end
end
