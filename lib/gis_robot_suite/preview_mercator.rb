# frozen_string_literal: true

module GisRobotSuite
  # Helper methods for assembling a Web Mercator projection for a thumbnail.
  # The including class also needs to include GdalCommands and provide `wgs84_path`,
  # which corresponds to the actual data for the thumbnail in EPSG:4326.
  module PreviewMercator
    private

    # Regular EPSG:3857, unless the data has a wider gap around 0° than around 180° (e.g. Pacific
    # islands either side of 180°), in which case wrap around the world the other way, putting the
    # seam in that gap so the data is centered and nothing crosses it.
    def mercator
      @mercator ||= begin
        xmin, _, xmax, = wgs84_extent
        east = extent_between(0, 180) if xmax - xmin > 180
        west = extent_between(-180, 0) if east
        if east && west && east[0] - west[2] > (180 - east[2]) + (west[0] + 180)
          @central_meridian = (east[0] + west[2] + 360) / 2
          @central_meridian -= 360 if @central_meridian > 180
          "+proj=merc +a=6378137 +b=6378137 +lon_0=#{@central_meridian} +x_0=0 +y_0=0 +k=1 +units=m +no_defs"
        else
          'EPSG:3857'
        end
      end
    end

    # Where the Mercator is centred: 0° unless it's been flipped to the other side of the world
    def central_meridian
      mercator
      @central_meridian || 0
    end

    def wgs84_extent = @wgs84_extent ||= extent_of(wgs84_path)

    # The extent of the data between two meridians, or nil if there's none there
    def extent_between(west, east)
      dest = pipeline wgs84_path, "between_#{west}.fgb", ['clip', '--bbox', [west, -90, east, 90].join(',')], promote_to_multi
      extent_of(dest) if feature_count(dest).positive?
    end
  end
end
