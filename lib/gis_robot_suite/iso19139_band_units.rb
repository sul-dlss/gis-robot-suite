# frozen_string_literal: true

module GisRobotSuite
  # Corrects the band units in an ISO 19139 document derived from an ArcGIS export.
  #
  # ArcGIS2ISO19139.xsl substitutes a fixed "Unified Code of Units of Measure" identifier
  # whenever the source <valUnit><UOM> carries no unit name or symbol, which is worse
  # than useless: it makes the object appear to have a "unit" which isn't a unit at all.
  #
  # Where the export declares a vertical coordinate system, its unit is the unit the band
  # values are in, so record that. Otherwise record an explicit nil, which is what the
  # stylesheet should have emitted.
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

    UCUM_CODE_SPACE = 'http://www.opengis.net/def/uom/UCUM/'
    private_constant :UCUM_CODE_SPACE

    # Where a unit is reported by ESRI's name because we have no UCUM symbol for it.
    ESRI_CODE_SPACE = 'ESRI'
    private_constant :ESRI_CODE_SPACE

    def self.apply(iso19139_file, esri_ng:, logger: nil)
      new(iso19139_file, esri_ng:, logger:).apply
    end

    # @param [String, Pathname] iso19139_file the document ArcgisMetadataTransformer produced
    # @param [Nokogiri::XML::Document] esri_ng the ESRI metadata it was derived from
    def initialize(iso19139_file, esri_ng:, logger: nil)
      @iso19139_file = Pathname(iso19139_file)
      @esri_ng = esri_ng
      @logger = logger
    end

    # Rewrites the ISO 19139 document in place, leaving it alone when the transform recorded
    # no placeholder units.
    #
    # @return [Pathname] the ISO 19139 document
    def apply
      return iso19139_file if placeholder_units.empty?

      log_units
      placeholder_units.each { |units| rewrite(units) }
      iso19139_file.write(iso19139_ng.to_xml(indent: 2))
      iso19139_file
    end

    private

    attr_reader :iso19139_file, :esri_ng, :logger

    # Reparsed without the transform's indentation so that the whole document reserializes
    # consistently, rather than leaving the rewritten elements oddly indented.
    def iso19139_ng
      @iso19139_ng ||= Nokogiri::XML(iso19139_file.read, &:noblanks)
    end

    def vertical_crs
      @vertical_crs ||= EsriVerticalCrs.new(esri_ng)
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

    def rewrite(units)
      units.replace(vertical_crs.unit? ? unit_definition(units) : '<units gco:nilReason="missing"/>')
    end

    # Built as a string so that the gmd, gco and gml prefixes resolve against the
    # declarations the transform put on the root element.
    #
    # @return [String]
    def unit_definition(units)
      "<units><gml:UnitDefinition#{gml_id_attribute(units)}>#{definition_children.join}</gml:UnitDefinition></units>"
    end

    # gml:UnitDefinition orders identifier before name, then quantityType, then
    # catalogSymbol -- the same order ArcGIS2ISO19139.xsl emits them in.
    #
    # @return [Array<String>]
    def definition_children
      [
        "<gml:identifier codeSpace=\"#{identifier_code_space}\">#{identifier}</gml:identifier>",
        "<gml:name>#{vertical_crs.unit_name}</gml:name>",
        quantity_type && "<gml:quantityType>#{quantity_type}</gml:quantityType>",
        vertical_crs.unit_symbol && "<gml:catalogSymbol codeSpace=\"#{UCUM_CODE_SPACE}\">#{vertical_crs.unit_symbol}</gml:catalogSymbol>"
      ].compact
    end

    def identifier
      vertical_crs.unit_symbol || vertical_crs.unit_name
    end

    def identifier_code_space
      vertical_crs.unit_symbol ? UCUM_CODE_SPACE : ESRI_CODE_SPACE
    end

    # The kind of quantity the band holds, e.g. "length". ArcGIS records it per band, but
    # writes the same value for every band of a raster, so the first one stands for all.
    #
    # @return [String, nil]
    def quantity_type
      @quantity_type = esri_ng.at_xpath('//covDim/Band/valUnit/UOM/@type')&.value.presence unless defined?(@quantity_type)
      @quantity_type
    end

    # Keeps the gml:id the transform generated, so that any reference to it still resolves.
    def gml_id_attribute(units)
      gml_id = units.at_xpath('gml:UnitDefinition/@gml:id', NS)&.value
      gml_id.present? ? %( gml:id="#{gml_id}") : ''
    end

    def log_units
      unless vertical_crs.unit?
        logger&.info("extract-iso19139: no vertical coordinate system declared; recording #{placeholder_units.size} band unit(s) as missing")
        return
      end

      logger&.info("extract-iso19139: recording band units as #{vertical_crs.unit_name} from the declared vertical coordinate system")
      return if vertical_crs.datum?

      logger&.info("extract-iso19139: vertical datum is #{vertical_crs.datum_name.inspect}, so the unit is recorded without a reference surface")
    end
  end
end
