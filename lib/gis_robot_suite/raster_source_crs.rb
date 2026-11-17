# frozen_string_literal: true

require 'json'
require 'shellwords'

module GisRobotSuite
  # Gives raster derivative generators a CRS to reproject from when the raster has none of its own.
  #
  # Some GeoTIFFs are georeferenced by nothing but a world file (.tfw), with no GeoTIFF keys, .prj or
  # .aux.xml, so GDAL finds no CRS at all. Converting one to a GoogleMapsCompatible COG then reads
  # its coordinates as EPSG:3857 metres, and for coordinates in degrees that fails with "Could not
  # find an appropriate zoom level"; gdalwarp can't reproject it either. Others declare an
  # engineering CRS PROJ can't relate to anything (see RasterBoundingBox#usable_source_crs?). For
  # those, the map projection cocina records stands in.
  #
  # The CRS is assigned on a VRT, never on the master: editing the master would invalidate the
  # checksums cocina recorded for it during assembly.
  #
  # The including class provides `input_path`, `fallback_crs` and `logger`.
  module RasterSourceCrs
    # Raised when neither the raster nor the descriptive metadata names a projection GDAL can use
    class MissingSourceCrs < StandardError; end

    private

    # GDAL uses the CRS the raster declares, so only assign one when it declares nothing usable:
    # overriding a projection the file does state would misplace the data if the two disagreed.
    #
    # @return [String, nil] nil when the raster declares a usable CRS of its own
    # @raise [MissingSourceCrs] when it doesn't and there's no recognizable fallback
    def crs_to_assign
      return @crs_to_assign if defined?(@crs_to_assign)

      @crs_to_assign = usable_source_crs? ? nil : usable_fallback_crs
    end

    def usable_fallback_crs
      if fallback_crs.blank?
        raise MissingSourceCrs, "#{input_path} has no usable spatial reference system " \
                                'and no map projection was supplied to fall back on'
      end
      unless recognized_crs?(fallback_crs)
        raise MissingSourceCrs, "#{input_path} has no usable spatial reference system, and GDAL does not " \
                                "recognize the map projection supplied to fall back on: #{fallback_crs}"
      end

      logger&.info("#{input_path} declares no usable spatial reference system; assigning #{fallback_crs}")
      fallback_crs
    end

    # A VRT of the raster, carrying the CRS it needs assigned (if any) without copying any raster data
    def write_source_vrt(vrt_path)
      run_command 'gdal', 'raster', 'convert', '--overwrite', '--format', 'VRT', input_path, vrt_path
      run_command 'gdal', 'raster', 'edit', '--crs', crs_to_assign, vrt_path if crs_to_assign
    end

    def usable_source_crs?
      projjson = JSON.parse(run_command('gdal', 'raster', 'info', '-f', 'json', input_path)[:stdout_str])
                     .dig('stac', 'proj:projjson')

      projjson.present? && projjson['type'] != 'EngineeringCRS'
    end

    # Descriptive metadata can record a projection GDAL has no definition for, or a garbled one
    def recognized_crs?(crs)
      run_command 'gdalsrsinfo', '-o', 'wkt2', crs
      true
    rescue SystemCommandNonzeroExit
      false
    end

    def run_command(*args) = GisRobotSuite.run_system_command(Shellwords.join(args.map(&:to_s)), logger: logger)
  end
end
