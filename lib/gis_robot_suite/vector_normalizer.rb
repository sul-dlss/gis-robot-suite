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
      normalize_prj

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
      # See http://www.gdal.org/ogr2ogr.html
      output_filepath = File.join(tmpdir, "#{geo_object_name}.shp") # output shapefile
      logger.info "normalize-vector: #{bare_druid} is projecting #{geo_object_name} to EPSG:4326"
      Kernel.system("env SHAPE_ENCODING= #{Settings.gdal_path}ogr2ogr -progress -t_srs '#{wkt}' '#{output_filepath}' '#{vector_filepath}'", exception: true) # prevent recoding
      raise "normalize-vector: #{bare_druid} failed to reproject #{vector_filepath}" unless File.size?(output_filepath)
    end

    def normalize_prj
      output_filepath = File.join(tmpdir, "#{geo_object_name}.prj")
      logger.debug "normalize-vector: #{bare_druid} overwriting #{output_filepath}"
      File.write(output_filepath, wkt)
    end

    def wkt
      # Well Known Text. It’s a text markup language for expressing geometries in vector data.
      @wkt ||= URI.open('https://spatialreference.org/ref/epsg/4326/prettywkt/').read
    end
  end
end
