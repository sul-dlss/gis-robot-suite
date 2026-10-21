# frozen_string_literal: true

module GisRobotSuite
  # Draws the basemap under a vector preview from Natural Earth's 1:10m layers, in greys like those of
  # CARTO Positron, the viewer's basemap: water, land, lakes, country borders, and state and province
  # borders on canvases small enough to show them. The layers are checked in to config/natural_earth;
  # bin/load_natural_earth.sh rebuilds them.
  class NaturalEarthBasemap
    include GdalCommands

    DATA_DIR = Pathname(__dir__).join('../../config/natural_earth').expand_path

    # Burn values, and the color each is drawn in
    WATER = 0
    LAND = 1
    LAKE = 2
    STATE = 3
    COUNTRY = 4
    COLORS = { WATER => [212, 218, 220], LAND => [250, 250, 248], LAKE => [212, 218, 220], STATE => [222, 222, 222], COUNTRY => [192, 192, 192] }.freeze

    BORDER_WIDTH = 2.0 # pixels
    STATES_BELOW = 10_000 # metres per pixel; state and province borders are only drawn on finer canvases
    EARTH_RADIUS = 6_378_137.0 # metres; the sphere Web Mercator projects
    POLAR_BOXES = { 'EPSG:3413' => [-180, 60, 180, 90], 'EPSG:3031' => [-180, -90, 180, -60] }.freeze

    # extent is the canvas in crs's units (metres), size its width and height in pixels. A Mercator
    # flipped round to the other side of the world says where it's centred with central_meridian.
    def self.render(output_path:, extent:, crs:, size:, central_meridian: 0, logger: nil)
      new(output_path:, extent:, crs:, size:, central_meridian:, logger:).render
    end

    def initialize(output_path:, extent:, crs:, size:, central_meridian: 0, logger: nil)
      @output_path = Pathname(output_path)
      @extent = extent
      @crs = crs
      @size = size
      @central_meridian = central_meridian
      @logger = logger
    end

    # An RGB image of the basemap at output_path, whose path it returns; its working files go alongside
    def render
      classes = path("#{output_path.basename('.*')}_classes.tif")
      gdal 'raster', 'create', '--size', "#{size},#{size}", '--bbox', extent.join(','), '--crs', crs, '--ot', 'Byte', '--burn', WATER, classes
      (layers('land.fgb') + layers('minor_islands.fgb')).each { |layer| burn classes, LAND, layer }
      layers('lakes.fgb').each { |layer| burn classes, LAKE, layer }
      layers('states.fgb', BORDER_WIDTH).each { |layer| burn classes, STATE, layer } if pixel_size < STATES_BELOW
      layers('countries.fgb', BORDER_WIDTH).each { |layer| burn classes, COUNTRY, layer }

      File.write(path('basemap_colors.txt'), COLORS.map { |value, rgb| "#{value} #{rgb.join(' ')}\n" }.join)
      gdal 'raster', 'color-map', '--color-selection', 'exact', '--color-map', path('basemap_colors.txt'), classes, output_path
      output_path
    end

    private

    attr_reader :output_path, :extent, :crs, :size, :central_meridian, :logger

    def work = output_path.dirname

    def pixel_size = (extent[2] - extent[0]) / size

    # A Natural Earth layer cut to the canvas, reprojected, and simplified to half a pixel, one file per
    # box in #boxes. Borders are widened to width pixels.
    def layers(name, width = nil)
      boxes.each_with_index.map do |box, i|
        steps = [['clip', '--bbox', box.join(',')], ['reproject', '--dst-crs', crs], geom('simplify', '--tolerance', pixel_size / 2)]
        steps += buffer(width / 2 * pixel_size) if width
        pipeline DATA_DIR / name, "basemap_#{i}_#{name}", *steps, promote_to_multi
      end
    end

    # The canvas's extent in degrees, to cut Natural Earth to before reprojecting it: two boxes, either
    # side of 180°, if the canvas spans that, so nothing crosses the seam of a flipped Mercator
    def boxes
      return [POLAR_BOXES.fetch(crs)] if POLAR_BOXES.key?(crs)

      limit = VectorPreviewGenerator::WEB_MERCATOR_LAT
      west, east = [extent[0], extent[2]].map { |x| central_meridian + degrees(x / EARTH_RADIUS) }
      south, north = [extent[1], extent[3]].map { |y| degrees(Math.atan(Math.sinh(y / EARTH_RADIUS))).clamp(-limit, limit) }
      return [[-180, south, 180, north]] if east - west >= 360

      shift = ((west + 180) / 360).floor * 360
      west -= shift
      east -= shift
      east <= 180 ? [[west, south, east, north]] : [[west, south, 180, north], [-180, south, east - 360, north]]
    end

    def degrees(radians) = radians * 180 / Math::PI
  end
end
