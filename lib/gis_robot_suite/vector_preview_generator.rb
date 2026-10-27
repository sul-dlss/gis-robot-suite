# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'shellwords'
require 'tmpdir'

module GisRobotSuite
  # Generates vector preview JP2 derivatives by first rasterizing the vector, then drawing it over a
  # Natural Earth basemap (see NaturalEarthBasemap).
  class VectorPreviewGenerator
    include GdalCommands
    include PreviewMercator

    SIZE = 512 # pixels along each side of the thumbnail
    SUPERSAMPLE = 2
    PADDING = 0.1 # of the data's larger dimension, on every side
    MIN_SIDE = 1000.0 # metres; used for data with no extent, like a single point
    WEB_MERCATOR_LAT = 85.0511 # Web Mercator is undefined beyond this

    # Based on ogm-viewer's light-theme defaults
    DATA_COLOR = [0, 113, 236].freeze
    STROKE_COLOR = [0, 22, 148].freeze
    OPACITY = 0.8

    # Larger than what the viewer draws, so they're easy to see in a small image
    OUTLINE_WIDTH = 2.0
    LINE_WIDTH = 6.0
    POINT_RADIUS = 8.0
    POINT_MIN_RADIUS = 1.0
    POINT_STROKE = 2.0
    POINT_COVERAGE = 0.1
    LINE_COVERAGE = 0.2
    SPECK_SIZE = 4.0 # a polygon part smaller than this is drawn as a dot this wide

    # SQL queries used to determine the geometry type
    POLYGONS = "OGR_GEOMETRY IN ('POLYGON','MULTIPOLYGON')"
    LINES = "OGR_GEOMETRY IN ('LINESTRING','MULTILINESTRING')"
    POINTS = "OGR_GEOMETRY IN ('POINT','MULTIPOINT')"

    # "Burn" values, i.e. how dark the corresponding feature is drawn
    MAX_STACK = 4
    OUTLINE = 100
    LINE = 150
    POINT_EDGE = 200
    POINT_FILL = 201

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
      reproject
      rasterize
      colorize
    ensure
      FileUtils.rm_rf(@work) if @work
    end

    private

    attr_reader :input_path, :output_path, :logger, :work

    # Make the thumbnail in Web Mercator, since that's what the viewer uses. Then simplify to a quarter
    # of a thumbnail pixel, which can't be seen, so later steps never handle more detail than they can
    # draw (a kelp canopy traced from raster pixels can hold millions of vertices).
    def reproject
      pipeline input_path, 'wgs84.fgb', ['reproject', '--dst-crs', 'EPSG:4326'], *drop_attributes, promote_to_multi
      pipeline path('wgs84.fgb'), 'projected.fgb', *fit_to_projection, ['reproject', '--dst-crs', crs], promote_to_multi
      pipeline path('projected.fgb'), 'merc.fgb', geom('simplify', '--tolerance', pixel_size / (2 * SUPERSAMPLE)), promote_to_multi
    end

    # Clip to only where Web Mercator is reasonably defined. Polar data is segmentized instead, so
    # long edges still curve around the pole once they're reprojected.
    def fit_to_projection
      return [geom('segmentize', '--max-length', 1)] if polar_projection

      # Also clip to ±180°, since reprojecting wraps anything a hair past it round to the other side
      xmin, ymin, xmax, ymax = wgs84_extent
      return [] if [ymin, ymax].all? { |lat| lat.abs <= WEB_MERCATOR_LAT } && xmin >= -180 && xmax <= 180

      [['clip', '--bbox', [-180, -WEB_MERCATOR_LAT, 180, WEB_MERCATOR_LAT].join(',')]]
    end

    def crs = @crs ||= polar_projection || mercator

    # Data entirely beyond Web Mercator's limits (e.g. a station at a pole) would be clipped away
    # completely, so it's drawn in north or south polar stereographic instead
    def polar_projection = { 'EPSG:3413' => wgs84_extent[1] > WEB_MERCATOR_LAT, 'EPSG:3031' => wgs84_extent[3] < -WEB_MERCATOR_LAT }.key(true)

    def wgs84_path = path('wgs84.fgb')

    def rasterize
      canvas = path('canvas.tif')
      # --add only adds to a raster that already exists, so an empty one is made first
      gdal 'vector', 'rasterize', '--size', "#{pixels},#{pixels}", '--extent', extent.join(','), '--init', '0', '--burn', '0', '--ot', 'Byte', path('merc.fgb'), canvas
      gdal 'vector', 'rasterize', '--update', '--add', '--burn', '1', '--where', POLYGONS, path('merc.fgb'), canvas if any?(POLYGONS)

      # In the viewer's layer order: fills, outlines, lines, points
      burn canvas, OUTLINE, outlines
      burn canvas, OUTLINE, specks
      burn canvas, LINE, buffered('lines', LINES, thinned('ST_Length', 1, LINE_WIDTH) / 2) if any?(LINES)
      burn canvas, POINT_EDGE, buffered('point_edges', POINTS, point_radius + point_stroke) if point_stroke.positive?
      burn canvas, POINT_FILL, buffered('point_fills', POINTS, point_radius)
    end

    # The thumbnail doesn't draw attributes, so they're dropped up front rather than carried through
    # every step, which also means one whose encoding is broken (a .dbf with no .cpg) can't fail a write.
    # After reprojecting, since 3.11's select loses the layer's CRS.
    def drop_attributes
      fields = vector_info(input_path)['layers'].first['fields'].flat_map { |field| ['--fields', field['name']] }
      fields.empty? ? [] : [['select', '--exclude', *fields]]
    end

    # Polygon boundaries as lines, widened to the outline width
    def outlines
      rings = geom('set-type', '--geometry-type', 'MULTILINESTRING')
      pipeline path('merc.fgb'), 'outlines.fgb', select(POLYGONS), rings, *buffer(thinned('ST_Perimeter', 2, OUTLINE_WIDTH) / 2 * pixel_size) if any?(POLYGONS)
    end

    # A dot for each polygon part too small to see at thumbnail scale (atolls across an ocean), so the
    # data doesn't vanish into its own extent. Needs GDAL's SQLite dialect to have SpatiaLite.
    def specks
      small = "ST_Dimension(GEOMETRY) = 2 AND ST_Area(GEOMETRY) < #{(SPECK_SIZE * pixel_size)**2}"
      centroids = ['sql', '--dialect', 'SQLITE', '--sql', %(SELECT ST_Centroid(GEOMETRY) AS geometry FROM "#{layer}" WHERE #{small})]
      pipeline path('merc.fgb'), 'specks.fgb', geom('explode-collections'), centroids, *buffer(SPECK_SIZE / 2 * pixel_size) if any?(POLYGONS)
    end

    # Features matching 'where', grown by a distance in thumbnail pixels: a point or a hairline
    # becomes something with area at thumbnail scale
    def buffered(name, where, radius)
      pipeline path('merc.fgb'), "#{name}.fgb", select(where), *buffer(radius * pixel_size) if any?(where)
    end

    # 3.11's `vector filter --where` writes nothing when the clause tests OGR_GEOMETRY (`vector info
    # --where` and `rasterize --where` count the same clause correctly), so select with OGR SQL instead
    def select(where)
      ['sql', '--dialect', 'OGRSQL', '--sql', %(SELECT * FROM "#{layer}" WHERE #{where})]
    end

    # Points shrink as there are more of them, so a dense layer still reads as points rather than as
    # one merged shape: the radius at which they'd cover POINT_COVERAGE of the canvas if none
    # overlapped, kept between POINT_MIN_RADIUS and POINT_RADIUS
    def point_radius
      @point_radius ||= Math.sqrt(POINT_COVERAGE * (SIZE**2) / (Math::PI * [count(POINTS), 1].max)).clamp(POINT_MIN_RADIUS, POINT_RADIUS)
    end

    # A dot too small for its edge to show is drawn without one
    def point_stroke = point_radius >= 3 ? POINT_STROKE : 0

    # Lines and outlines thin out as there's more of them, for the reason points shrink: the width at
    # which they'd cover LINE_COVERAGE of the canvas if none overlapped, kept between 1 pixel and widest
    def thinned(measure, dimension, widest)
      sql = %(SELECT SUM(#{measure}(GEOMETRY)) AS total FROM "#{layer}" WHERE ST_Dimension(GEOMETRY) = #{dimension})
      total = vector_info(path('merc.fgb'), '--features', '--dialect', 'SQLITE', '--sql', sql)['layers'].first['features'].first['properties']['total'].to_f
      (LINE_COVERAGE * (SIZE**2) * pixel_size / [total, pixel_size].max).clamp(1.0, widest)
    end

    # The data as a translucent overlay, composited over the basemap by gdalwarp: warping an image with
    # an alpha band onto one that already exists blends the two by that alpha
    def colorize
      File.write(path('colors.txt'), color_map)
      gdal 'raster', 'color-map', '--add-alpha', '--color-map', path('colors.txt'), path('canvas.tif'), path('overlay.tif')
      basemap = NaturalEarthBasemap.render(output_path: path('basemap.tif'), extent:, crs:, size: pixels, central_meridian:, logger:)
      run 'gdalwarp', '-q', path('overlay.tif'), basemap
      gdal 'raster', 'resize', '--size', "#{SIZE},#{SIZE}", '--resampling', 'average', basemap, path('rgb.tif')
      Jp2Converter.convert(input_path: path('rgb.tif'), output_path: output_path, logger: logger)
    end

    # "value R G B A" lines for `raster color-map`, each the color and opacity the viewer draws that
    # mark with. Values between entries are interpolated, which only matters across the plateau that
    # keeps a stack deeper than MAX_STACK at the deepest fill.
    def color_map
      fill = ->(stack) { [DATA_COLOR, 1 - ((1 - OPACITY)**stack)] }
      fills = (1..MAX_STACK).to_h { |stack| [stack, fill.call(stack)] }
      marks = { OUTLINE => over([STROKE_COLOR, OPACITY], fill.call(1)), LINE => [DATA_COLOR, OPACITY],
                POINT_EDGE => [STROKE_COLOR, OPACITY], POINT_FILL => [DATA_COLOR, OPACITY] }
      entries = { 0 => [[0, 0, 0], 0], **fills, OUTLINE - 1 => fill.call(MAX_STACK), **marks }
      entries.map { |value, (rgb, alpha)| "#{value} #{rgb.map(&:round).join(' ')} #{(alpha * 255).round}\n" }.join
    end

    # One translucent [color, alpha] drawn over another, the way the browser composites the viewer's layers
    def over((top, top_alpha), (bottom, bottom_alpha))
      alpha = top_alpha + (bottom_alpha * (1 - top_alpha))
      [top.zip(bottom).map { |t, b| ((t * top_alpha) + (b * bottom_alpha * (1 - top_alpha))) / alpha }, alpha]
    end

    # A square canvas centred on the data, padded, in metres
    def extent
      @extent ||= begin
        xmin, ymin, xmax, ymax = extent_of(path('projected.fgb'))
        side = [[xmax - xmin, ymax - ymin].max * (1 + (2 * PADDING)), MIN_SIDE].max
        x, y = [xmin + xmax, ymin + ymax].map { |sum| sum / 2 }
        [x - (side / 2), y - (side / 2), x + (side / 2), y + (side / 2)]
      end
    end

    def pixels = SIZE * SUPERSAMPLE

    # Metres per thumbnail pixel
    def pixel_size = (extent[2] - extent[0]) / SIZE

    def any?(where) = count(where).positive?

    def count(where) = ((@counts ||= {})[where] ||= feature_count(path('merc.fgb'), '--where', where))

    def layer = @layer ||= vector_info(path('merc.fgb'))['layers'].first['name']
  end
end
