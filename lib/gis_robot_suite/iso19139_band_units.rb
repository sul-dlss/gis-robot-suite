# frozen_string_literal: true

module GisRobotSuite
  # Corrects the band units in an ISO 19139 document derived from an ArcGIS export.
  #
  # ArcGIS2ISO19139.xsl substitutes a fixed "Unified Code of Units of Measure" identifier
  # whenever the source <valUnit><UOM> carries no unit name or symbol, which is worse than
  # useless: it makes the object appear to have a "unit" which isn't a unit at all, it is
  # the name of a code system. ArcGIS writes a bare <UOM type="length"/> for almost every
  # raster we hold, so almost every record we publish carries the placeholder.
  #
  # Record an explicit nil instead, which is what the stylesheet should have emitted.
  class Iso19139BandUnits
    NS = {
      'gmd' => 'http://www.isotc211.org/2005/gmd',
      'gco' => 'http://www.isotc211.org/2005/gco',
      'gml' => 'http://www.opengis.net/gml'
    }.freeze
    private_constant :NS

    # The literal ArcGIS2ISO19139.xsl emits in place of a unit it does not have.
    PLACEHOLDER = 'Unified Code of Units of Measure'
    private_constant :PLACEHOLDER

    def self.apply(iso19139_file, logger: nil)
      new(iso19139_file, logger:).apply
    end

    # @param [String, Pathname] iso19139_file the document ArcgisMetadataTransformer produced
    def initialize(iso19139_file, logger: nil)
      @iso19139_file = Pathname(iso19139_file)
      @logger = logger
    end

    # Rewrites the ISO 19139 document in place, leaving it alone when the transform recorded
    # no placeholder units.
    #
    # @return [Pathname] the ISO 19139 document
    def apply
      return iso19139_file if placeholder_units.empty?

      logger&.info("extract-iso19139: recording #{placeholder_units.size} band unit(s) as missing")
      placeholder_units.each { |units| units.replace('<units gco:nilReason="missing"/>') }
      iso19139_file.write(iso19139_ng.to_xml(indent: 2))
      iso19139_file
    end

    private

    attr_reader :iso19139_file, :logger

    # Reparsed without the transform's indentation so that the whole document reserializes
    # consistently, rather than leaving the rewritten elements oddly indented.
    def iso19139_ng
      @iso19139_ng ||= Nokogiri::XML(iso19139_file.read, &:noblanks)
    end

    # @return [Array<Nokogiri::XML::Element>] the gmd:units the transform could not fill in.
    #   A genuinely populated unit is left alone.
    def placeholder_units
      @placeholder_units ||= iso19139_ng.xpath('//gmd:MD_Band/gmd:units', NS).select { |units| placeholder?(units) }
    end

    def placeholder?(units)
      return false if units.at_xpath('@gco:nilReason', NS)

      identifier = units.at_xpath('gml:UnitDefinition/gml:identifier', NS)
      identifier.nil? || identifier.text.strip == PLACEHOLDER
    end
  end
end
