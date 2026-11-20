# frozen_string_literal: true

module GisRobotSuite
  # Derives the EPSG:4326 bounding box of vector data.
  #
  # GDAL transforms the geometry in memory and we aggregate the envelope from the result, so no
  # reprojected copy of the data is written anywhere. Aggregating over every geometry gives the
  # true extent: transforming only the corners of the native envelope would understate it, because
  # straight edges in a projected CRS curve once they are expressed in longitude and latitude.
  #
  # Longitudes are aggregated twice, once as they are and once shifted into [0, 360], and the
  # narrower result kept, so that data either side of the antimeridian gets the extent it has
  # rather than one spanning the world. See Antimeridian.
  class VectorBoundingBox
    TARGET_SRID = 4326

    # @param rootdir [String] the druid's staging directory, holding content/
    # @param esri_ng [Nokogiri::XML::Document] the ArcGIS metadata, for a projection to fall back on
    def initialize(rootdir:, esri_ng:, logger:, bare_druid:)
      @rootdir = rootdir
      @esri_ng = esri_ng
      @logger = logger
      @bare_druid = bare_druid
    end

    # @return [BoundingBox]
    def bounding_box
      envelope = transformed_envelope.transform_values(&:to_f)
      west, east = Antimeridian.longitudes(envelope.values_at('w', 'e'), envelope.values_at('shifted_w', 'shifted_e'))

      BoundingBox.new(west:, east:, north: envelope['n'], south: envelope['s'])
    end

    private

    attr_reader :rootdir, :esri_ng, :logger, :bare_druid

    def transformed_envelope
      result = GisRobotSuite.run_system_command(
        "#{Settings.gdal_path}gdal vector info -f json --features --dialect sqlite " \
        "--sql #{Shellwords.escape(envelope_sql)} #{Shellwords.escape(dataset)}",
        logger:
      )
      envelope = JSON.parse(result[:stdout_str]).dig('layers', 0, 'features', 0, 'properties')

      return envelope if envelope.present? && envelope.values.none?(&:nil?)

      raise "bounding box: #{bare_druid} #{layer_name} has no geometry to derive a bounding box from"
    end

    # Aggregating the per-geometry envelope rather than calling ST_Extent, which GDAL's built-in
    # SQLite dialect does not provide. Quotes are required around the layer name because
    # identifiers starting with a number are rejected by SQLite unless quoted.
    #
    # ST_Shift_Longitude moves each negative longitude east by 360°, vertex by vertex, so it also
    # mends a ring that crosses the antimeridian, which ST_Transform returns jumping from 180 to -180.
    def envelope_sql
      shifted = 'ST_Shift_Longitude(g)'

      'select min(ST_MinX(g)) as w, min(ST_MinY(g)) as s, max(ST_MaxX(g)) as e, max(ST_MaxY(g)) as n, ' \
        "min(ST_MinX(#{shifted})) as shifted_w, max(ST_MaxX(#{shifted})) as shifted_e " \
        "from (select ST_Transform(geometry, #{TARGET_SRID}) as g " \
        "from \"#{layer_name}\" where geometry is not null)"
    end

    # ST_Transform needs a source CRS, so when the data declares none, name the projection the
    # ArcGIS metadata records. An OGR VRT attaches it without rewriting the data, and GDAL
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

    # The projection the ArcGIS metadata records, used when the data file declares none.
    def fallback_crs
      EsriReferenceSystem.crs(esri_ng) ||
        raise("bounding box: #{bare_druid} #{layer_name} has no spatial reference system " \
              'and the ArcGIS metadata names none to fall back on')
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
  end
end
