# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'shellwords'
require 'tmpdir'

module GisRobotSuite
  # Generates vector preview JP2 derivatives by first rasterizing the vector.
  class VectorPreviewGenerator
    SIZE = 512 # pixels along each side of the thumbnail
    SUPERSAMPLE = 2
    PADDING = 0.1 # of the data's larger dimension, on every side
    MIN_SIDE = 1000.0 # metres; used for data with no extent, like a single point
    WEB_MERCATOR_LAT = 85.0511 # Web Mercator is undefined beyond this

    # Based on ogm-viewer's light-theme defaults
    BACKGROUND = [248, 248, 248].freeze
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

    # GDAL 3.12 moved 3.11's `vector geom <step>`s up a level, and renamed set-type
    RENAMED_GEOM_STEPS = { 'set-type' => 'set-geom-type' }.freeze

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

    def path(name) = work / name

    # Make the thumbnail in Web Mercator, since that's what the viewer uses. Then simplify to a quarter
    # of a thumbnail pixel, which can't be seen, so later steps never handle more detail than they can
    # draw (a kelp canopy traced from raster pixels can hold millions of vertices).
    def reproject
      pipeline input_path, 'wgs84.fgb', ['reproject', '--dst-crs', 'EPSG:4326'], *drop_attributes, promote_to_multi
      pipeline path('wgs84.fgb'), 'projected.fgb', *fit_to_projection, ['reproject', '--dst-crs', polar_projection || mercator], promote_to_multi
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

    # Data entirely beyond Web Mercator's limits (e.g. a station at a pole) would be clipped away
    # completely, so it's drawn in north or south polar stereographic instead
    def polar_projection = { 'EPSG:3413' => wgs84_extent[1] > WEB_MERCATOR_LAT, 'EPSG:3031' => wgs84_extent[3] < -WEB_MERCATOR_LAT }.key(true)

    def wgs84_extent = @wgs84_extent ||= extent_of(path('wgs84.fgb'))

    # Regular EPSG:3857, unless the data has a wider gap around 0° than around 180° (e.g. Pacific
    # islands either side of 180°), in which case wrap around the world the other way, putting the
    # seam in that gap so the data is centered and nothing crosses it
    def mercator
      xmin, _, xmax, = wgs84_extent
      return 'EPSG:3857' if xmax - xmin <= 180

      east = extent_between(0, 180)
      west = extent_between(-180, 0)
      return 'EPSG:3857' unless east && west && east[0] - west[2] > (180 - east[2]) + (west[0] + 180)

      central_meridian = (east[0] + west[2] + 360) / 2
      central_meridian -= 360 if central_meridian > 180
      "+proj=merc +a=6378137 +b=6378137 +lon_0=#{central_meridian} +x_0=0 +y_0=0 +k=1 +units=m +no_defs"
    end

    # The extent of the data between two meridians, or nil if there's none there
    def extent_between(west, east)
      dest = pipeline path('wgs84.fgb'), "between_#{west}.fgb", ['clip', '--bbox', [west, -90, east, 90].join(',')], promote_to_multi
      extent_of(dest) if feature_count(dest).positive?
    end

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

    def burn(canvas, value, source)
      gdal 'vector', 'rasterize', '--update', '--burn', value, source, canvas if source
    end

    # The thumbnail doesn't draw attributes, so they're dropped up front rather than carried through
    # every step, which also means one whose encoding is broken (a .dbf with no .cpg) can't fail a write.
    # After reprojecting, since 3.11's select loses the layer's CRS.
    def drop_attributes
      fields = info(input_path)['layers'].first['fields'].flat_map { |field| ['--fields', field['name']] }
      fields.empty? ? [] : [['select', '--exclude', *fields]]
    end

    # Polygon boundaries as lines, widened to the outline width
    def outlines
      rings = geom('set-type', '--geometry-type', 'MULTILINESTRING')
      pipeline path('merc.fgb'), 'outlines.fgb', select(POLYGONS), rings, *buffer(thinned('ST_Perimeter', 2, OUTLINE_WIDTH) / 2) if any?(POLYGONS)
    end

    # A dot for each polygon part too small to see at thumbnail scale (atolls across an ocean), so the
    # data doesn't vanish into its own extent. Needs GDAL's SQLite dialect to have SpatiaLite.
    def specks
      small = "ST_Dimension(GEOMETRY) = 2 AND ST_Area(GEOMETRY) < #{(SPECK_SIZE * pixel_size)**2}"
      centroids = ['sql', '--dialect', 'SQLITE', '--sql', %(SELECT ST_Centroid(GEOMETRY) AS geometry FROM "#{layer}" WHERE #{small})]
      pipeline path('merc.fgb'), 'specks.fgb', geom('explode-collections'), centroids, *buffer(SPECK_SIZE / 2) if any?(POLYGONS)
    end

    # Features matching 'where', grown by a distance in thumbnail pixels: a point or a hairline
    # becomes something with area at thumbnail scale
    def buffered(name, where, radius)
      pipeline path('merc.fgb'), "#{name}.fgb", select(where), *buffer(radius) if any?(where)
    end

    # 3.11's `vector filter --where` writes nothing when the clause tests OGR_GEOMETRY (`vector info
    # --where` and `rasterize --where` count the same clause correctly), so select with OGR SQL instead
    def select(where)
      ['sql', '--dialect', 'OGRSQL', '--sql', %(SELECT * FROM "#{layer}" WHERE #{where})]
    end

    # Exploded first so each line is buffered on its own: buffering a multi-part geometry unions every
    # part's buffer, which for a polygon with thousands of rings can run out of memory. Rounded with
    # 3 segments per quarter circle rather than 8, which can't be seen at this size but saves a lot
    # of vertices. 3.11's buffer leaves the layer declaring the points or lines it started with,
    # which FlatGeoBuf then refuses to write polygons into, so the type is set to match.
    def buffer(radius)
      [geom('explode-collections'), geom('buffer', '--distance', radius * pixel_size, '--quadrant-segments', 3),
       geom('set-type', '--geometry-type', 'MULTIPOLYGON')]
    end

    # FlatGeoBuf takes one geometry type per layer, so mixed single and multi geometry is promoted
    def promote_to_multi = geom('set-type', '--multi')

    # Figure out the right name for the GDAL command depending on the version
    def geom(step, *options) = legacy_geom_steps? ? ['geom', step, *options] : [RENAMED_GEOM_STEPS.fetch(step, step), *options]

    def legacy_geom_steps? = gdal_version < Gem::Version.new('3.12')
    def gdal_version = @gdal_version ||= Gem::Version.new(gdal('--version')[/GDAL (\d+\.\d+\.\d+)/, 1])

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
      total = info(path('merc.fgb'), '--features', '--dialect', 'SQLITE', '--sql', sql)['layers'].first['features'].first['properties']['total'].to_f
      (LINE_COVERAGE * (SIZE**2) * pixel_size / [total, pixel_size].max).clamp(1.0, widest)
    end

    def colorize
      File.write(path('colors.txt'), color_map)
      gdal 'raster', 'color-map', '--color-map', path('colors.txt'), path('canvas.tif'), path('rgb_big.tif')
      gdal 'raster', 'resize', '--size', "#{SIZE},#{SIZE}", '--resampling', 'average', path('rgb_big.tif'), path('rgb.tif')
      Jp2Converter.convert(input_path: path('rgb.tif'), output_path: output_path, logger: logger)
    end

    # "value R G B" lines for `raster color-map`, each the color the viewer composites for that mark.
    # Values between entries are interpolated, which only matters across the plateau that keeps a
    # stack deeper than MAX_STACK at the deepest fill.
    def color_map
      fill = ->(stack) { over(DATA_COLOR, BACKGROUND, 1 - ((1 - OPACITY)**stack)) }
      fills = (1..MAX_STACK).to_h { |stack| [stack, fill.call(stack)] }
      marks = { OUTLINE => over(STROKE_COLOR, fill.call(1), OPACITY), LINE => over(DATA_COLOR, BACKGROUND, OPACITY),
                POINT_EDGE => over(STROKE_COLOR, BACKGROUND, OPACITY), POINT_FILL => over(DATA_COLOR, BACKGROUND, OPACITY) }
      { 0 => BACKGROUND, **fills, OUTLINE - 1 => fill.call(MAX_STACK), **marks }.map { |value, rgb| "#{value} #{rgb.map(&:round).join(' ')}\n" }.join
    end

    # One color drawn over another at an opacity, the way the browser composites the viewer's layers
    def over(top, bottom, alpha) = top.zip(bottom).map { |t, b| (t * alpha) + (b * (1 - alpha)) }

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

    def layer = @layer ||= info(path('merc.fgb'))['layers'].first['name']
    def extent_of(file) = info(file)['layers'].first['geometryFields'].first['extent']
    def feature_count(file, *options) = info(file, *options)['layers'].first['featureCount']
    def info(file, *options) = JSON.parse(gdal('vector', 'info', '-f', 'json', *options, file))

    # One `gdal vector pipeline` from source through steps into the working file name, whose path it
    # returns. FlatGeoBuf in between because GeoJSON can't record a CRS that has no EPSG code, and
    # the flipped Mercator we sometimes use would come back from it as WGS 84.
    def pipeline(source, name, *steps)
      dest = path(name)
      gdal 'vector', 'pipeline', 'read', source, *steps.flat_map { |step| ['!', *step] }, '!', 'write', dest
      dest
    end

    def gdal(*args)
      GisRobotSuite.run_system_command(Shellwords.join(['gdal', *args.map(&:to_s)]), logger: logger)[:stdout_str]
    end
  end
end
