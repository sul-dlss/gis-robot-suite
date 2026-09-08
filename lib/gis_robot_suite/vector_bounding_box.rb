# frozen_string_literal: true

module GisRobotSuite
  # Derives the EPSG:4326 bounding box of vector data.
  #
  # GDAL transforms the geometry in memory and we aggregate the envelope from the result, so no
  # reprojected copy of the data is written anywhere. Aggregating over every geometry gives the
  # true extent: transforming only the corners of the native envelope would understate it, because
  # straight edges in a projected CRS curve once they are expressed in longitude and latitude.
  class VectorBoundingBox
    TARGET_SRID = 4326

    def initialize(cocina_object:, logger:, rootdir:)
      @cocina_object = cocina_object
      @logger = logger
      @rootdir = rootdir
    end

    # @return [Array<Float>] ulx, uly, lrx, lry (west, north, east, south) in EPSG:4326
    def bounding_box
      envelope = transformed_envelope

      [envelope['w'].to_f, envelope['n'].to_f, envelope['e'].to_f, envelope['s'].to_f]
    end

    private

    attr_reader :cocina_object, :logger, :rootdir

    def transformed_envelope
      result = GisRobotSuite.run_system_command(
        "#{Settings.gdal_path}gdal vector info -f json --features --dialect sqlite " \
        "--sql #{Shellwords.escape(envelope_sql)} #{Shellwords.escape(dataset)}",
        logger:
      )
      envelope = JSON.parse(result[:stdout_str]).dig('layers', 0, 'features', 0, 'properties')

      return envelope if envelope.present? && envelope.values.none?(&:nil?)

      raise "extract-boundingbox: #{bare_druid} #{layer_name} has no geometry to derive a bounding box from"
    end

    # Aggregating the per-geometry envelope rather than calling ST_Extent, which GDAL's built-in
    # SQLite dialect does not provide. Quotes are required around the layer name because
    # identifiers starting with a number are rejected by SQLite unless quoted.
    def envelope_sql
      transformed = "ST_Transform(geometry, #{TARGET_SRID})"

      "select min(ST_MinX(#{transformed})) as w, min(ST_MinY(#{transformed})) as s, " \
        "max(ST_MaxX(#{transformed})) as e, max(ST_MaxY(#{transformed})) as n " \
        "from \"#{layer_name}\" where geometry is not null"
    end

    # ST_Transform needs a source CRS, so when the data declares none, name the projection the
    # descriptive metadata records. An OGR VRT attaches it without rewriting the data, and GDAL
    # accepts the VRT document itself in place of a filename, so nothing is written to disk.
    # Legacy ESRI datasets were frequently accessioned without a .prj.
    def dataset
      return vector_filepath if declared_coordinate_system

      <<~VRT.gsub(/\s*\n\s*/, '')
        <OGRVRTDataSource>
          <OGRVRTLayer name="#{layer_name}">
            <SrcDataSource relativeToVRT="0">#{vector_filepath}</SrcDataSource>
            <SrcLayer>#{layer_name}</SrcLayer>
            <LayerSRS>#{fallback_crs}</LayerSRS>
          </OGRVRTLayer>
        </OGRVRTDataSource>
      VRT
    end

    # The projection recorded in the descriptive metadata, used when the data file declares none.
    # generate-descriptive runs earlier in gisAssemblyWF and raises when it cannot determine one,
    # so this is only missing for a projection GDAL has no code for.
    def fallback_crs
      GisRobotSuite.map_projection(cocina_object) ||
        raise("extract-boundingbox: #{bare_druid} #{layer_name} has no spatial reference system " \
              'and cocina records no map projection to fall back on')
    end

    # The coordinate system the data file itself declares, which for a shapefile means its .prj.
    def declared_coordinate_system
      vector_info.dig('layers', 0, 'geometryFields', 0, 'coordinateSystem')
    end

    # Read the layer name from the data rather than deriving it from the filename: GeoJSON layers
    # are not always named after the file that holds them.
    def layer_name
      vector_info.dig('layers', 0, 'name')
    end

    def vector_info
      @vector_info ||= JSON.parse(
        GisRobotSuite.run_system_command(
          "#{Settings.gdal_path}gdal vector info -f json #{Shellwords.escape(vector_filepath)}", logger:
        )[:stdout_str]
      )
    end

    def vector_filepath
      @vector_filepath ||= Dir.glob("#{rootdir}/content/*.{shp,geojson}").first
    end

    def bare_druid
      @bare_druid ||= cocina_object.externalIdentifier.delete_prefix('druid:')
    end
  end
end
