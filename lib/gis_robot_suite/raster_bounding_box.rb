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
  class RasterBoundingBox
    TARGET_CRS = 'EPSG:4326'

    def initialize(cocina_object:, logger:, rootdir:)
      @cocina_object = cocina_object
      @logger = logger
      @rootdir = rootdir
    end

    # @return [Array<Float>] ulx, uly, lrx, lry (west, north, east, south) in EPSG:4326
    def bounding_box
      raise "extract-boundingbox: #{bare_druid} cannot locate data type" unless data_format
      raise "extract-boundingbox: #{bare_druid} has unsupported Raster data type: #{data_format}" unless geotiff?

      corners = warped_corner_coordinates
      ulx, uly = corners['upperLeft']
      lrx, lry = corners['lowerRight']

      [ulx, uly, lrx, lry].map { |coordinate| coordinate.to_s.strip.to_f }
    end

    private

    attr_reader :cocina_object, :logger, :rootdir

    def warped_corner_coordinates
      Tempfile.create(['boundingbox', '.vrt']) do |vrt|
        GisRobotSuite.run_system_command(
          "#{Settings.gdal_path}gdalwarp -of VRT #{source_crs_option}-t_srs #{TARGET_CRS} " \
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

    # The projection recorded in the descriptive metadata, used when the data file declares none
    # that PROJ can work with. generate-descriptive runs earlier in gisAssemblyWF and raises when
    # it cannot determine one, so this is only missing for a projection GDAL has no code for.
    def fallback_crs
      GisRobotSuite.map_projection(cocina_object) ||
        raise("extract-boundingbox: #{bare_druid} #{geo_object_name} has no usable spatial reference " \
              'system and cocina records no map projection to fall back on')
    end

    def raster_info(path)
      @raster_info ||= {}
      @raster_info[path] ||= JSON.parse(
        GisRobotSuite.run_system_command(
          "#{Settings.gdal_path}gdal raster info -f json #{Shellwords.escape(path)}", logger:
        )[:stdout_str]
      )
    end

    def data_format
      @data_format ||= GisRobotSuite.data_format(cocina_object)
    end

    def geotiff?
      data_format == 'GeoTIFF'
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

    def bare_druid
      @bare_druid ||= cocina_object.externalIdentifier.delete_prefix('druid:')
    end

    def content_dir
      @content_dir ||= "#{rootdir}/content"
    end
  end
end
