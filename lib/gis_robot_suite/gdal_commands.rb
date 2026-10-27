# frozen_string_literal: true

require 'json'
require 'shellwords'

module GisRobotSuite
  # `gdal` commands shared by the vector preview and the basemap drawn under it. The including class
  # provides the `work` directory they write into and the `logger` they log to. Written for GDAL 3.11,
  # prod's version, and works the same on later ones.
  module GdalCommands
    # GDAL 3.12 moved 3.11's `vector geom <step>`s up a level, and renamed set-type
    RENAMED_GEOM_STEPS = { 'set-type' => 'set-geom-type' }.freeze

    private

    def path(name) = work / name

    # One `gdal vector pipeline` from source through steps into the working file name, whose path it
    # returns. FlatGeoBuf in between because GeoJSON can't record a CRS that has no EPSG code, and
    # the flipped Mercator we sometimes use would come back from it as WGS 84.
    def pipeline(source, name, *steps)
      dest = path(name)
      gdal 'vector', 'pipeline', 'read', source, *steps.flat_map { |step| ['!', *step] }, '!', 'write', dest
      dest
    end

    def burn(canvas, value, source)
      gdal 'vector', 'rasterize', '--update', '--burn', value, source, canvas if source
    end

    # Exploded first so each line is buffered on its own: buffering a multi-part geometry unions every
    # part's buffer, which for a polygon with thousands of rings can run out of memory. Rounded with
    # 3 segments per quarter circle rather than 8, which can't be seen at this size but saves a lot
    # of vertices. 3.11's buffer leaves the layer declaring the points or lines it started with,
    # which FlatGeoBuf then refuses to write polygons into, so the type is set to match.
    def buffer(distance)
      [geom('explode-collections'), geom('buffer', '--distance', distance, '--quadrant-segments', 3),
       geom('set-type', '--geometry-type', 'MULTIPOLYGON')]
    end

    # FlatGeoBuf takes one geometry type per layer, so mixed single and multi geometry is promoted
    def promote_to_multi = geom('set-type', '--multi')

    # Figure out the right name for the GDAL command depending on the version
    def geom(step, *options) = legacy_geom_steps? ? ['geom', step, *options] : [RENAMED_GEOM_STEPS.fetch(step, step), *options]

    def legacy_geom_steps? = gdal_version < Gem::Version.new('3.12')
    def gdal_version = @gdal_version ||= Gem::Version.new(gdal('--version')[/GDAL (\d+\.\d+\.\d+)/, 1])

    def extent_of(file) = info(file)['layers'].first['geometryFields'].first['extent']
    def feature_count(file, *options) = info(file, *options)['layers'].first['featureCount']
    def info(file, *options) = JSON.parse(gdal('vector', 'info', '-f', 'json', *options, file))

    def gdal(*args)
      GisRobotSuite.run_system_command(Shellwords.join(['gdal', *args.map(&:to_s)]), logger: logger)[:stdout_str]
    end
  end
end
