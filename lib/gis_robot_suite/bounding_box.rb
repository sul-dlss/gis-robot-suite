# frozen_string_literal: true

module GisRobotSuite
  # The extent of a dataset in EPSG:4326 decimal degrees, computed from the data itself.
  #
  # West is greater than east when the extent crosses the antimeridian, as cocina, ISO 19139,
  # FGDC and Solr's ENVELOPE all expect; see Antimeridian.
  #
  # extract-iso19139-metadata computes it and writes it into the ISO 19139 record, which is
  # where extract-fgdc-metadata and generate-descriptive read it from, so that every copy of
  # the extent SDR publishes is this one rather than whatever ArcGIS recorded.
  BoundingBox = Data.define(:west, :east, :north, :south) do
    # Pick the calculator from the data staged: a vector if there is a shapefile or GeoJSON,
    # otherwise a raster if there is a GeoTIFF.
    #
    # @param rootdir [String] the druid's staging directory, holding content/
    # @param esri_ng [Nokogiri::XML::Document] the ArcGIS metadata, for a projection to fall back
    #   on when the data declares none
    # @return [BoundingBox]
    def self.from_data(rootdir:, esri_ng:, logger:, bare_druid:)
      content_dir = "#{rootdir}/content"
      calculator = if Dir.glob("#{content_dir}/*.{shp,geojson}").any?
                     VectorBoundingBox
                   elsif Dir.glob("#{content_dir}/*.tif").any?
                     RasterBoundingBox
                   else
                     raise "bounding box: #{bare_druid} has no shapefile, GeoJSON or GeoTIFF in #{content_dir} to derive one from"
                   end

      calculator.new(rootdir:, esri_ng:, logger:, bare_druid:).bounding_box
    end

    def initialize(west:, east:, north:, south:)
      unless north >= south && [west, east].all? { |longitude| longitude.between?(-180, 180) }
        raise ArgumentError, "invalid bounding box: is not (#{north} >= #{south} and #{west}, #{east} within [-180, 180])"
      end

      super
    end

    def crosses_antimeridian?
      west > east
    end
  end
end
