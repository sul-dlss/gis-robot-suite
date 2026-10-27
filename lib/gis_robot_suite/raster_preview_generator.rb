# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'shellwords'
require 'tmpdir'

module GisRobotSuite
  # Generates raster preview JP2 derivatives the way the viewer (ogm-viewer) draws a COG: in Web
  # Mercator, at its opacity over a Natural Earth basemap (see NaturalEarthBasemap), with nodata
  # transparent, and a single band of numbers on its viridis ramp.
  class RasterPreviewGenerator
    include GdalCommands
    include PreviewMercator

    SIZE = 512 # pixels along each side of the thumbnail
    SUPERSAMPLE = 2
    PADDING = 0.1 # of the data's larger dimension, on every side
    OPACITY = 0.8

    # matplotlib's viridis, the viewer's default ramp, at nine even stops
    VIRIDIS = [[68, 1, 84], [71, 44, 122], [59, 81, 139], [44, 113, 142], [33, 144, 141],
               [39, 173, 129], [92, 200, 99], [170, 220, 50], [253, 231, 37]].freeze

    def self.generate(input_path:, output_path:, logger: nil)
      new(input_path: input_path, output_path: output_path, logger: logger).generate
    end

    def initialize(input_path:, output_path:, logger: nil)
      @input_path = input_path
      @output_path = output_path
      @logger = logger
    end

    def generate
      @work = Pathname(Dir.mktmpdir("#{File.basename(output_path, '.jp2')}_preview", output_path.parent))
      trace_outline
      basemap = NaturalEarthBasemap.render(output_path: path('basemap.tif'), extent:, crs: mercator, size: pixels, central_meridian:, logger:)
      run 'gdalwarp', '-q', '-srcalpha', overlay, basemap
      gdal 'raster', 'resize', '--size', "#{SIZE},#{SIZE}", '--resampling', 'average', basemap, path('rgb.tif')
      Jp2Converter.convert(input_path: path('rgb.tif'), output_path: output_path, logger: logger)
    ensure
      FileUtils.rm_rf(@work) if @work
    end

    private

    attr_reader :input_path, :output_path, :logger, :work

    def wgs84_path = path('outline.fgb')

    # Where the raster has data, outlined in EPSG:4326. Only uses the first band
    # as bytes; GDAL only takes an alpha band as a mask when it's bytes, and the
    # alpha is all the outline needs.
    def trace_outline
      run 'gdalwarp', '-q', '-overwrite', '-t_srs', 'EPSG:4326', '-ts', 256, 0, '-r', 'near', '-srcband', 1, '-ot', 'Byte', '-dstalpha', input_path, path('coarse.tif')
      gdal 'raster', 'footprint', '--overwrite', '--band', 1, path('coarse.tif'), wgs84_path
      return if feature_count(wgs84_path).positive?

      corners = JSON.parse(gdal('raster', 'info', '-f', 'json', path('coarse.tif')))['wgs84Extent']
      File.write(path('extent.geojson'), { type: 'Feature', properties: {}, geometry: corners }.to_json)
      gdal 'vector', 'convert', '--overwrite', path('extent.geojson'), wgs84_path
    end

    # How ogm-viewer will actually draw it, depending on the bands
    def kind
      return :rgb if bands.size >= 3
      return :palette if bands.first['colorTable']
      return :grey if bands.first['type'] == 'Byte'

      :scalar
    end

    # Generate a web mercator .tif of the data with alpha applied
    def overlay
      case kind
      when :rgb
        run 'gdal_translate', '-q', '-ot', 'Byte', *rgb_stretch, '-scale_4', 0, 255, 0, alpha, warp(1, 2, 3, resampling: 'bilinear'), path('overlay.tif')
        path('overlay.tif')
      when :palette
        entries = bands.first['colorTable']['entries'].each_with_index.map { |(r, g, b), index| "#{index} #{r} #{g} #{b}\n" }
        colored(warp(1, resampling: 'near'), entries.join, exact: true)
      when :grey
        colored(warp(1, resampling: 'bilinear'), "0 0 0 0\n255 255 255 255\n")
      when :scalar
        min, max = range
        stops = VIRIDIS.each_with_index.map { |rgb, i| "#{min + ((max - min) * i / (VIRIDIS.size - 1))} #{rgb.join(' ')}\n" }
        colored(warp(1, resampling: 'bilinear'), stops.join)
      end
    end

    # The raster warped onto the canvas grid, plus an alpha band that's transparent wherever it has no
    # data (see #trace_outline).
    def warp(*source_bands, resampling:)
      run 'gdalwarp', '-q', '-overwrite', '-t_srs', mercator, '-te', *extent, '-ts', pixels, pixels, '-r', resampling,
          *source_bands.flat_map { |band| ['-srcband', band] }, '-dstalpha', input_path, path('warped.tif')
      path('warped.tif')
    end

    # A single warped band colored by a color map, stacked with its alpha scaled to the viewer's opacity
    def colored(warped, color_map, exact: false)
      File.write(path('colors.txt'), color_map)
      gdal 'raster', 'color-map', *(exact ? ['--color-selection', 'exact'] : []), '--color-map', path('colors.txt'), warped, path('colored.tif')
      run 'gdal_translate', '-q', '-ot', 'Byte', '-b', 2, '-scale', 0, 255, 0, alpha, warped, path('alpha.tif')
      # On the canvas grid explicitly: color-map and gdal_translate can disagree in the last decimal
      # place of the resolution, and by default stack wants them identical
      resolution = (extent[2] - extent[0]) / pixels
      gdal 'raster', 'stack', '--overwrite', '--bbox', extent.join(','), '--resolution', "#{resolution},#{resolution}",
           path('colored.tif'), path('alpha.tif'), path('overlay.tif')
      path('overlay.tif')
    end

    def alpha = (255 * OPACITY).round

    # Bytes are drawn as they are; anything wider is stretched to bytes, all three bands across one
    # range so a band with a little less in it doesn't tint the whole image
    def rgb_stretch
      return [] if bands.first(3).all? { |band| band['type'] == 'Byte' }

      mins, maxes = stats.first(3).transpose
      (1..3).flat_map { |band| ["-scale_#{band}", mins.min, maxes.max, 0, 255] }
    end

    # The first band's range, used for the color ramp
    def range
      min, max = stats.first
      max > min ? [min, max] : [min, min + 1]
    end

    # Each band's [min, max] (without leaving a .aux.xml of them beside the source)
    def stats
      @stats ||= JSON.parse(gdal('raster', 'info', '-f', 'json', '--approx-stats', '--config', 'GDAL_PAM_ENABLED=NO', input_path))['bands']
                     .map { |band| [band['minimum'], band['maximum']] }
    end

    # Band info from GDAL
    def bands = @bands ||= JSON.parse(gdal('raster', 'info', '-f', 'json', input_path))['bands']

    # Dimensions of a square canvas centred on the outline, with padding, in
    # Web Mercator meters
    def extent
      @extent ||= begin
        limit = VectorPreviewGenerator::WEB_MERCATOR_LAT
        projected = pipeline wgs84_path, 'outline_projected.fgb', ['clip', '--bbox', [-180, -limit, 180, limit].join(',')],
                             ['reproject', '--dst-crs', mercator], promote_to_multi
        xmin, ymin, xmax, ymax = extent_of(projected)
        side = [xmax - xmin, ymax - ymin].max * (1 + (2 * PADDING))
        x, y = [xmin + xmax, ymin + ymax].map { |sum| sum / 2 }
        [x - (side / 2), y - (side / 2), x + (side / 2), y + (side / 2)]
      end
    end

    def pixels = SIZE * SUPERSAMPLE
  end
end
