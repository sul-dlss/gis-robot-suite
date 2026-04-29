# frozen_string_literal: true

module GisRobotSuite
  class DataFileFinder
    FILE_MIMETYPES =
      [
        ['.shp', 'application/vnd.shp'],
        ['.shx', 'application/vnd.shx'],
        ['.vat.dbf', 'application/octet-stream'],
        ['.dbf', 'application/vnd.dbf'],
        ['.cpg', 'text/plain'],
        ['.json', 'application/geo+json'],
        ['.geojson', 'application/geo+json'],
        ['.pmtiles', 'application/vnd.pmtiles'],
        ['.tif', 'image/tiff'],
        ['.ovr', 'application/octet-stream'], # pyramid_ovr_raster_file
        ['.rrd', 'application/octet-stream'], # pyramid_rrd_raster_file
        ['.aux', 'application/octet-stream'], # auxiliary_stats_raster_file
        ['.sbn', 'application/octet-stream'], # spatial_index_n_shapefile
        ['.sbx', 'application/octet-stream'], # spatial_index_x_shapefile
        ['.aux.xml', 'application/xml'], # auxiliary_stats_xml_raster_file
        ['.prj', 'text/plain'],
        ['.tfw', 'text/plain'] # world_raster_file
      ].freeze

    # See https://github.com/sul-dlss/gis-robot-suite/wiki/GIS-SSDI-Data-input-formats-and-derivatives
    def self.find(content_dir:)
      FILE_MIMETYPES.map do |ext, _mimetype|
        Dir.glob("#{content_dir}/*#{ext}").first
      end.compact
    end
  end
end
