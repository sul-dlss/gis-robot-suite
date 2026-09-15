# frozen_string_literal: true

module GisRobotSuite
  # The vertical coordinate system an ArcGIS export declares, if any.
  #
  # ArcGIS records this in exactly one place: <coordRef><peXml>, which holds an escaped
  # ESRI projection engine document whose <WKT> is a comma-joined GEOGCS[...],VERTCS[...]
  # (or PROJCS[...],VERTCS[...]). Nothing else in the export carries it -- <csUnits>
  # reports the horizontal unit only -- and ArcGIS2ISO19139.xsl drops peXml entirely, so
  # anything derived from the ISO 19139 has to come back here for the vertical unit. The
  # GeoTIFF is no help either: the arcGRID conversion writes no VerticalUnits (4099) geokey.
  class EsriVerticalCrs
    # ESRI's linear unit names mapped to the UCUM symbols a gml:UnitDefinition wants.
    UCUM_SYMBOLS = {
      'Centimeter' => 'cm',
      'Fathom' => '[fth_i]',
      'Foot' => '[ft_i]',
      'Foot_Intl' => '[ft_i]',
      'Foot_US' => '[ft_us]',
      'Kilometer' => 'km',
      'Meter' => 'm',
      'Metre' => 'm',
      'Millimeter' => 'mm',
      'Yard' => '[yd_i]'
    }.freeze

    # @param [Nokogiri::XML::Document] esri_ng the ESRI metadata exported from ArcGIS
    def initialize(esri_ng)
      @esri_ng = esri_ng
    end

    # @return [Boolean] whether a vertical coordinate system naming a unit was declared
    def unit?
      unit_name.present?
    end

    # @return [String, nil] the unit as ESRI names it, e.g. "Meter"
    def unit_name
      vertcs&.slice(/UNIT\["([^"]*)"/, 1)
    end

    # @return [String, nil] the UCUM symbol for #unit_name, e.g. "m". Nil when ESRI's name
    #   is not one we recognize, leaving #unit_name as the only way to report the unit.
    def unit_symbol
      UCUM_SYMBOLS[unit_name]
    end

    # The best single string available for the unit, for consumers that want one label
    # rather than a symbol and a name recorded separately. GDAL's band unit type is such a
    # consumer: it is freeform, so ESRI's own name for an unrecognized unit is worth more
    # there than an empty field.
    #
    # @return [String, nil] e.g. "m", or "Smoot" for a unit with no UCUM symbol
    def unit_label
      unit_symbol || unit_name
    end

    # ArcGIS writes VDATUM["Unknown"] under VERTCS["Unknown VCS"] when a Z unit was set
    # without choosing a vertical datum, which is the usual case for these legacy rasters.
    # The unit is still the unit the values are in; only the reference surface is unknown,
    # so callers should report the unit without asserting a datum.
    #
    # @return [Boolean] whether the declared vertical datum names something real
    def datum?
      datum_name.present? && !datum_name.casecmp?('unknown')
    end

    # @return [String, nil] the vertical datum as ESRI names it, e.g. "Unknown"
    def datum_name
      vertcs&.slice(/VDATUM\["([^"]*)"/, 1)
    end

    private

    attr_reader :esri_ng

    # The VERTCS clause runs to the end of the WKT, because ESRI appends it to the
    # horizontal coordinate system rather than nesting it.
    #
    # @return [String, nil]
    def vertcs
      @vertcs = wkt&.slice(/VERTCS\[.*\]/m) unless defined?(@vertcs)
      @vertcs
    end

    # Two rounds of unescaping are needed: taking the text of <peXml> resolves the &lt; and
    # &gt; wrapping the projection engine document, and parsing that resolves the &quot;
    # around the names inside the WKT.
    #
    # @return [String, nil] the coordinate system WKT
    def wkt
      return @wkt if defined?(@wkt)

      pe_xml = esri_ng.at_xpath('//coordRef/peXml')&.text
      @wkt = pe_xml.present? ? Nokogiri::XML(pe_xml).at_xpath('//WKT')&.text : nil
    end
  end
end
