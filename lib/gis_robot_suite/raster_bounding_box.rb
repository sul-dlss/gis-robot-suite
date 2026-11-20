# frozen_string_literal: true

require 'tempfile'

module GisRobotSuite
  # Derives the EPSG:4326 bounding box of raster data.
  #
  # gdalwarp writes a warped VRT: a small XML description of the reprojection, with none of the
  # pixel data materialized. Reading its corner coordinates gives the same numbers as reprojecting
  # the whole raster, because gdalwarp densifies the edges when it computes the output grid.
  #
  # The raster's own `wgs84Extent` would be cheaper still, but it reports only the four transformed
  # corners, so it understates the extent of anything whose edges curve appreciably in longitude
  # and latitude.
  #
  # gdalwarp puts the output's longitudes in [-180, 180], so a raster straddling the antimeridian
  # comes out spanning the world. When it comes out wider than a hemisphere, warp again with
  # longitudes centred on 180° instead, and keep the narrower. See Antimeridian.
  class RasterBoundingBox
    TARGET_CRS = 'EPSG:4326'
    ANTIMERIDIAN = 180

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
      ulx, uly, lrx, lry = warped_extent
      measurements = [[ulx, lrx]]
      measurements << warped_extent(center_longitude: ANTIMERIDIAN).values_at(0, 2) if lrx - ulx > 180
      west, east = Antimeridian.longitudes(*measurements)

      BoundingBox.new(west:, east:, north: uly, south: lry)
    end

    private

    attr_reader :rootdir, :esri_ng, :logger, :bare_druid

    # @return [Array<Float>] ulx, uly, lrx, lry of the raster warped to EPSG:4326
    def warped_extent(center_longitude: nil)
      corners = warped_corner_coordinates(center_longitude:)
      ulx, uly = corners['upperLeft']
      lrx, lry = corners['lowerRight']

      [ulx, uly, lrx, lry].map { |coordinate| coordinate.to_s.strip.to_f }
    end

    # CENTER_LONG has PROJ wrap the output longitudes to within 180° of it, rather than of 0°.
    def warped_corner_coordinates(center_longitude: nil)
      center_long_option = center_longitude ? "--config CENTER_LONG #{center_longitude} " : ''

      Tempfile.create(['boundingbox', '.vrt']) do |vrt|
        GisRobotSuite.run_system_command(
          "#{Settings.gdal_path}gdalwarp -of VRT #{center_long_option}#{source_crs_option}-t_srs #{TARGET_CRS} " \
          "#{Shellwords.escape(input_filepath)} #{Shellwords.escape(vrt.path)}",
          logger:
        )

        raster_info(vrt.path).fetch('cornerCoordinates')
      end
    end

    def source_crs_option
      # GDAL uses the CRS the file declares, so only name one when the file declares nothing usable.
      return '' if usable_source_crs?

      "-s_srs #{Shellwords.escape(fallback_crs)} "
    end

    # ArcGRID rasters converted before the converter learned to stamp the CRS carry an engineering
    # CRS, e.g. ENGCRS["MOLLWEIDE"], which PROJ cannot relate to anything: GDAL's ArcGRID driver
    # could not map the bare projection name in the grid's prj.adf to a known CRS.
    def usable_source_crs?
      projjson = raster_info(input_filepath).dig('stac', 'proj:projjson')

      projjson.present? && projjson['type'] != 'EngineeringCRS'
    end

    # The projection the ArcGIS metadata records, used when the data file declares none that PROJ
    # can work with.
    def fallback_crs
      EsriReferenceSystem.crs(esri_ng) ||
        raise("bounding box: #{bare_druid} #{geo_object_name} has no usable spatial reference " \
              'system and the ArcGIS metadata names none to fall back on')
    end

    def raster_info(path)
      @raster_info ||= {}
      @raster_info[path] ||= JSON.parse(
        GisRobotSuite.run_system_command(
          "#{Settings.gdal_path}gdal raster info -f json #{Shellwords.escape(path)}", logger:
        )[:stdout_str]
      )
    end

    def input_filepath
      @input_filepath ||= "#{content_dir}/#{geo_object_name}.tif"
    end

    def geo_object_name
      @geo_object_name ||= begin
        filepath = Dir.glob("#{content_dir}/*.tif.xml").first
        filepath ? File.basename(filepath, '.tif.xml') : nil
      end
    end

    def content_dir
      @content_dir ||= "#{rootdir}/content"
    end
  end
end
