# frozen_string_literal: true

module GisRobotSuite
  # Picks the best longitude pair to describe an extent with.
  #
  # The minimum and maximum longitude of data either side of the antimeridian, such as Pacific
  # islands, span nearly the whole world: Kiribati comes out as -174.5 to 176.8. Measured with
  # longitudes wrapped around 180° instead of 0°, it is 169.5 to 216.9, the extent it "really has".
  #
  # To capture this, we can 'wrap' [169.5, 216.9] back into [-180, 180], so an extent that
  # crosses the antimeridian has its west greater than its east, as ISO 19139 and Solr's
  # ENVELOPE field expect. Without this, Solr will show it as spanning most of the world.
  module Antimeridian
    # @param candidates [Array<Array(Float, Float)>] list of [west, east] longitude pairs
    # @return [Array(Float, Float)] [west, east] narrowest longitude pair, allowing west > east
    def self.longitudes(*candidates)
      west, east = candidates.min_by { |candidate_west, candidate_east| candidate_east - candidate_west }
      return [-180.0, 180.0] if east - west >= 360

      [wrap(west), wrap(east)]
    end

    def self.wrap(longitude)
      longitude -= 360 while longitude > 180
      longitude += 360 while longitude < -180
      longitude
    end
    private_class_method :wrap
  end
end
