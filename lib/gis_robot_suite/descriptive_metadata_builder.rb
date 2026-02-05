# frozen_string_literal: true

module GisRobotSuite
  # Builds cocina descriptive metadata from ISO19139
  class DescriptiveMetadataBuilder # rubocop:disable Metrics/ClassLength
    GOOD_URI = /\A#{URI::RFC2396_PARSER.make_regexp(%w[http https])}\z/

    def self.build(cocina_model:, bare_druid:, iso19139_ng:, logger:)
      new(cocina_model:, bare_druid:, iso19139_ng:, logger:).build
    end

    # @param [Cocina::Models::DRO] cocina_model the current cocina object
    # @param [String] bare_druid
    # @param [Nokogiri::XML] iso19139_ng
    # @param [Logger] logger
    def initialize(cocina_model:, bare_druid:, iso19139_ng:, logger:)
      @cocina_model = cocina_model
      @bare_druid = bare_druid
      @iso19139_ng = iso19139_ng
      @logger = logger
    end

    attr_reader :cocina_model, :bare_druid, :iso19139_ng, :logger

    def build
      description_props = { title:, event:, form:, geographic:, language:, contributor:, note:, subject:, identifier:, purl:,
                            adminMetadata: admin_metadata, relatedResource: related_resource, access: }.compact
      Cocina::Models::Description.new(description_props)
    end

    NS = {
      'gmd' => 'http://www.isotc211.org/2005/gmd',
      'gco' => 'http://www.isotc211.org/2005/gco',
      'gts' => 'http://www.isotc211.org/2005/gts',
      'srv' => 'http://www.isotc211.org/2005/srv',
      'gml' => 'http://www.opengis.net/gml'
    }.freeze
    private_constant :NS

    private

    def data_id_node
      @data_id_node ||= iso19139_ng.xpath('//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification', NS)
    end

    def title
      title_node = data_id_node.xpath('gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString', NS)
      raise "Title is missing for #{bare_druid}." unless title_node.any?

      title = { value: title_node.text }

      [title, alternate_titles].flatten.compact
    end

    def alternate_titles
      alternate_nodes = data_id_node.xpath('gmd:citation/gmd:CI_Citation/gmd:alternateTitle/gco:CharacterString', NS)
      return unless alternate_nodes.any?

      [].tap do |alternates|
        alternates << alternate_nodes.map { |node| { value: node.text, type: 'alternative', displayLabel: 'Alternative title' } }
      end.flatten
    end

    def event
      citation_nodes = data_id_node.xpath('gmd:citation/gmd:CI_Citation', NS)

      [].tap do |events|
        events << extract_pubdate(citation_nodes)
                  .merge(extract_publishers(citation_nodes))
                  .merge(extract_edition(citation_nodes))
      end.flatten.reject(&:empty?)
    end

    def extract_publishers(nodes)
      contributors = []
      publisher_nodes = nodes.xpath("gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[text()='publisher']", NS)
      publisher_nodes.map do |node|
        if node.xpath('../../gmd:individualName/gco:CharacterString', NS).any?
          contributors << node.xpath('../../gmd:individualName/gco:CharacterString', NS).map do |name|
            { name: [{ value: name.xpath('../../gmd:individualName/gco:CharacterString', NS).text }],
              type: 'person',
              role: [{ value: 'publisher',
                       code: 'pbl',
                       uri: 'http://id.loc.gov/vocabulary/relators/pbl',
                       source: { code: 'marcrelator', uri: 'http://id.loc.gov/vocabulary/relators/' } }] }
          end
        end
        next unless node.xpath('../../gmd:organisationName/gco:CharacterString', NS).any?

        contributors << node.xpath('../../gmd:organisationName/gco:CharacterString', NS).map do |name|
          { name: [{ value: name.xpath('../../gmd:organisationName/gco:CharacterString', NS).text }],
            type: 'organization',
            role: [{ value: 'publisher',
                     code: 'pbl',
                     uri: 'http://id.loc.gov/vocabulary/relators/pbl',
                     source: { code: 'marcrelator', uri: 'http://id.loc.gov/vocabulary/relators/' } }] }
        end
      end
      { contributor: contributors.flatten }
    end

    def extract_pubdate(node)
      pub_date_node = node.xpath('gmd:date/gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode[@codeListValue="publication"]', NS)
      raise "Publication date is missing for #{bare_druid}." unless pub_date_node.any?

      pub_date = pub_date_node.xpath('../../gmd:date/gco:Date', NS).text
      pub_year = Date.parse(pub_date).strftime('%Y')
      dates = [{ value: pub_year, encoding: { code: 'w3cdtf' }, status: 'primary', type: 'publication' }]
      dates << extract_keyword_dates
      { date: dates.compact }
    end

    def extract_keyword_dates
      node = data_id_node.xpath('gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode[@codeListValue="temporal"]', NS)
      return unless node.any?

      keyword = node.xpath('../../gmd:keyword/gco:CharacterString', NS).text
      if keyword.size == 4 # YYYY
        { value: keyword, encoding: { code: 'w3cdtf' }, type: 'validity' }
      elsif keyword.include?('-') # YYYY-YYYY
        { structuredValue: [{ value: keyword.split('-').first, type: 'start' },
                            { value: keyword.split('-').last, type: 'end' }],
          encoding: { code: 'w3cdtf' },
          type: 'validity' }
      end
    end

    def extract_edition(node)
      edition = node.xpath('gmd:edition/gco:CharacterString', NS)
      return {} unless edition.any?

      { note: [{ type: 'edition', value: edition.text }] }
    end

    def form
      formats = [
        { value: 'Geospatial data', type: 'genre', uri: 'http://id.loc.gov/authorities/genreForms/gf2011026297', source: { code: 'lcgft' } },
        { value: 'cartographic dataset', type: 'genre', uri: 'http://rdvocab.info/termList/RDAContentType/1001', source: { code: 'rdacontent' } },
        { value: 'cartographic', type: 'resource type', source: { value: 'MODS resource types' } },
        { value: 'software, multimedia', type: 'resource type', source: { value: 'MODS resource types' } },
        { value: 'born digital', type: 'digital origin', source: { value: 'MODS digital origin terms' } },
        { value: 'Dataset', type: 'genre', source: { value: 'local' } }
      ]
      formats.tap do |forms|
        forms << distribution_format
        forms << map_projection
        forms << extent_form
      end.compact.flatten
    end

    def distribution_format
      format = iso19139_ng.xpath('//gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat/gmd:MD_Format/gmd:name/gco:CharacterString', NS)
      return unless format.any?

      { value: format.text, type: 'form' }
    end

    def map_projection
      proj = iso19139_ng.xpath('//gmd:MD_Metadata/gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier', NS)
      system = proj.xpath('gmd:codeSpace/gco:CharacterString', NS).text
      code = proj.xpath('gmd:code/gco:CharacterString', NS).text
      raise "Map projection is missing for #{bare_druid}." if system.empty? || code.empty?

      { value: "#{system}::#{code}", type: 'map projection' } # Uses '::' since the spec requires a version here (e.g., :7.4:) but it's generally left blank
    end

    def extent_form
      size = iso19139_ng.xpath('//gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:transferSize/gco:Real', NS)
      units = iso19139_ng.xpath(
        '//gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:unitsOfDistribution/gco:CharacterString', NS
      )
      return unless size.any? && units.any?

      value = [size.text, units.text].join(' ')
      { value:, type: 'extent' }
    end

    def geographic
      [].tap do |geographic|
        geographic << geo_forms
      end.flatten
    end

    def geo_forms
      forms = []
      forms.tap do |form|
        form << media_type
        form << data_type
        form << geometry
      end.compact
      { form: forms }
    end

    def media_type
      media, = media_type_format
      { value: media, type: 'media type', source: { value: 'IANA media type terms' } }
    end

    def data_type
      _, data = media_type_format
      return unless data

      { value: data, type: 'data format' }
    end

    def media_type_format
      format_name = iso19139_ng.xpath('//gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat/gmd:MD_Format/gmd:name', NS).text

      if format_name == 'GeoTIFF' || file_format == 'GeoTIFF'
        ['image/tiff', 'GeoTIFF']
      elsif format_name == 'Shapefile' || file_format == 'Shapefile'
        ['application/x-esri-shapefile', 'Shapefile']
      elsif format_name == 'GeoJSON' || file_format == 'GeoJSON'
        ['application/geo+json', 'GeoJSON']
      elsif format_name == 'Arc/Info Binary Grid' || file_format == 'ArcGRID'
        ['application/x-ogc-aig', 'ArcGRID']
      elsif format_name == 'Arc/Info ASCII Grid'
        ['application/x-ogc-aaigrid']
      else
        ['application/x-unknown']
      end
    end

    def geometry
      geometry_value = "Dataset##{geometry_type}"
      { value: geometry_value, type: 'type' }
    end

    def language
      lang_code_nodes = data_id_node.xpath('gmd:language/gmd:LanguageCode', NS)
      raise "Language missing for #{bare_druid}." unless lang_code_nodes.any?

      [].tap do |langs|
        langs << lang_code_nodes.map do |lang_node|
          extract_language(lang_node)
        end
      end.flatten
    end

    def extract_language(lang)
      code = lang.xpath('@codeListValue', NS).text
      code_source = lang.xpath('@codeSpace', NS).text
      raise "Missing language code or code source for #{bare_druid}." if code.empty? || code_source.empty?

      { code:, source: { code: code_source } }
    end

    def contributor
      contributor_nodes = data_id_node.xpath('gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty', NS)

      [].tap do |contribs|
        contribs << contributor_nodes.map do |node|
          extract_contributor(node) if node
        end.compact.flatten
      end.flatten
    end

    def extract_contributor(node)
      if node.xpath('gmd:individualName', NS).any? && node.xpath('gmd:role/gmd:CI_RoleCode/@codeListValue', NS).text == 'originator'
        { name: [{ value: node.xpath('gmd:individualName/gco:CharacterString', NS).first.text }],
          type: 'person',
          role: [{ source: { code: 'marcrelator' }, value: 'creator' }] }
      elsif node.xpath('gmd:organisationName', NS).any? && node.xpath('gmd:role/gmd:CI_RoleCode/@codeListValue', NS).text == 'originator'
        { name: [{ value: node.xpath('gmd:organisationName/gco:CharacterString', NS).first.text }],
          type: 'organization',
          role: [{ source: { code: 'marcrelator' }, value: 'creator' }] }
      end
    end

    def note
      [abstract_note, purpose_note, supplemental_note, related_pubs_note].compact.flatten
    end

    def abstract_note
      node = data_id_node.xpath('gmd:abstract/gco:CharacterString', NS)
      raise "Abstract missing for #{bare_druid}." unless node.any?

      { value: node.text, type: 'abstract', displayLabel: 'Abstract' } # abstract is not repeatable in ISO19139
    end

    def purpose_note
      node = data_id_node.xpath('gmd:purpose/gco:CharacterString', NS)
      return unless node.any?

      { value: node.first.text, type: 'other', displayLabel: 'Purpose' } # purpose is not repeatable in ISO19139
    end

    def supplemental_note
      node = data_id_node.xpath('gmd:supplementalInformation/gco:CharacterString', NS)
      return unless node.any?

      { value: node.first.text, type: 'other', displayLabel: 'Supplemental information' } # supplementalInformation is not repeatable in ISO19139
    end

    def subject
      [].tap do |subjects|
        subjects << keyword_subjects
        subjects << category_subjects
        subjects << temporal_subjects
        subjects << coordinates_subjects
      end.compact.flatten
    end

    def keyword_subjects
      keywords = data_id_node.xpath('gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString', NS)
      return unless keywords.any?

      keywords.map do |keyword|
        type = keyword_type(keyword)
        next unless type

        { value: keyword.text,
          type:,
          source: keyword_source(keyword) }.compact
      end.compact
    end

    def keyword_type(keyword)
      code = keyword.xpath('../../gmd:type/gmd:MD_KeywordTypeCode', NS).text

      if code == 'theme'
        'topic'
      elsif code == 'place'
        'place'
      end
    end

    def keyword_source(keyword)
      return unless keyword.xpath('../../gmd:thesaurusName/gmd:CI_Citation', NS).any?

      code = keyword.xpath('../../gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString', NS).text
      uri = valid_uri(keyword.xpath('../../gmd:thesaurusName/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString', NS).text)

      return { code:, uri: } unless code.include?('Library of Congress Subject Headings (LCSH)') # preserving logic from xslt to handle older records

      { code: 'lcsh', uri: }
    end

    def category_subjects
      nodes = data_id_node.xpath('gmd:topicCategory/gmd:MD_TopicCategoryCode', NS)
      return unless nodes.any?

      nodes.map do |node|
        label = CategoryMapper.label(node.text)
        continue if label.blank? # do not include subject if topic not mapped to label

        { source: { code: 'ISO19115TopicCategory', uri: 'http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_TopicCategoryCode' },
          value: label,
          uri: valid_uri(node.text),
          type: 'topic' }
      end
    end

    def temporal_subjects
      nodes = data_id_node.xpath('gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent', NS)
      return unless nodes.any?

      nodes.map do |node|
        { value: extract_time(node),
          type: 'time',
          encoding: { code: 'w3cdtf' } }
      end
    end

    def extract_time(node)
      if node.xpath('gml:TimePeriod', NS).any?
        begin_date = Date.parse(node.xpath('gml:TimePeriod/gml:beginPosition', NS).text).strftime('%Y')
        end_date = Date.parse(node.xpath('gml:TimePeriod/gml:endPosition', NS).text).strftime('%Y')
        "#{begin_date}-#{end_date}"
      else
        Date.parse(node.xpath('gml:TimeInstant/gml:timePosition', NS).text).strftime('%Y')
      end
    end

    def coordinates_subjects
      # use coordinates in native projection only, no longer reproject
      extent = data_id_node.xpath('gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox', NS)
      return unless extent.any?

      { value: coordinates(extent),
        type: 'map coordinates' } # also add field with the reference system
    end

    def coordinates(extent)
      west = extent.xpath('gmd:westBoundLongitude/gco:Decimal', NS).text
      east = extent.xpath('gmd:eastBoundLongitude/gco:Decimal', NS).text
      north = extent.xpath('gmd:northBoundLatitude/gco:Decimal', NS).text
      south = extent.xpath('gmd:southBoundLatitude/gco:Decimal', NS).text

      values = [west, east, north, south].map(&:to_f)
      to_coordinates_ddmmss(values)
    end

    def identifier
      return [] unless data_id_node.xpath('gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString[contains(text(), "doi")]', NS).any?

      [{ displayLabel: 'DOI',
         source: { code: 'doi' },
         value: data_id_node.xpath('gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString[contains(text(), "doi")]', NS).text }]
    end

    def purl
      @purl ||= Settings.purl.url + "/#{bare_druid}"
    end

    def related_resource
      [].tap do |resources|
        resources << scanned_maps
      end.compact.flatten
    end

    def scanned_maps
      maps = iso19139_ng.xpath('//gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:source/gmd:LI_Source', NS)

      return unless maps.xpath('gmd:description/gco:CharacterString[contains(text(), "Scanned map") or contains(text(), "Digitized map")]', NS).any?

      maps.map do |related_map|
        { type: 'has other format',
          displayLabel: 'Scanned map',
          title: [{ value: related_map.xpath('gmd:sourceCitation/gmd:CI_Citation/gmd:title/gco:CharacterString', NS).text }],
          identifier: [{ value: related_map.xpath('gmd:sourceCitation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString', NS).text }] }
      end
    end

    # rubocop:disable Layout/LineLength
    def related_pubs_note
      related_publications = data_id_node.xpath(
        'gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:otherCitationDetails/gco:CharacterString[contains(text(), "Related publication")]', NS
      )
      return unless related_publications.any?

      related_publications.map do |node|
        { type: 'citation/reference',
          displayLabel: 'Related publication',
          value: related_citation(node) }
      end
    end
    # rubocop:enable Layout/LineLength

    def related_citation(node)
      authors = node.xpath('../../gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:individualName/gco:CharacterString', NS).map(&:text)
                    .concat(node.xpath('../../gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString', NS).map(&:text))
      authors = authors.join(', ').chomp('.').concat('.') # Remove any existing ending middle initial period before adding period to end of authors string
      title = "\"#{node.xpath('../../gmd:title/gco:CharacterString', NS).text}.\"" # "Example article title"
      pub_date = node.xpath('../../gmd:date/gmd:CI_Date/gmd:date/gco:Date', NS).text
      pub_year = pub_date.present? ? "(#{Date.parse(pub_date).strftime('%Y')})." : nil # Year in parens (2023)
      series = node.xpath('../../gmd:series/gmd:CI_Series/gmd:name/gco:CharacterString', NS).text
      identifier = node.xpath('../../gmd:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString[contains(text(), "doi")]', NS)
      identifier_text = identifier.any? ? "Available at: #{identifier.text}" : nil

      [authors, title, series, pub_year, identifier_text].compact.join(' ')
    end

    def admin_metadata
      {}.merge({ contributor: [{ name: [{ value: 'Stanford' }] }] })
        .merge(admin_identifier)
        .merge(admin_langs)
        .merge(admin_events)
        .compact
    end

    def admin_identifier
      identifier = iso19139_ng.xpath('//gmd:MD_Metadata/gmd:fileIdentifier/gco:CharacterString', NS)
      raise "identifier not found in '//gmd:MD_Metadata/gmd:fileIdentifier/gco:CharacterString'" unless identifier.any?

      { identifier: [{ value: identifier.text }] }
    end

    def admin_langs
      langs = iso19139_ng.xpath('//gmd:MD_Metadata/gmd:language/gmd:LanguageCode', NS)
      return unless langs.any?

      data = langs.map do |lang|
        { code: lang.xpath('@codeListValue', NS).text,
          source: { code: lang.xpath('@codeSpace', NS).text } }
      end

      { language: data }
    end

    def admin_events
      datestamp = iso19139_ng.xpath('//gmd:MD_Metadata/gmd:dateStamp/gco:Date', NS).text
      return {} if datestamp.empty?

      events = []
      type = 'creation'
      # keep any existing adminMetadata events
      if existing_admin_events?
        events << cocina_model.description.adminMetadata&.event
        type = 'modification' if admin_creation_date?
      end

      events << { type:, date: [{ value: datestamp, encoding: { code: 'w3cdtf' } }] }
      { event: events.flatten }
    end

    def existing_admin_events?
      events = cocina_model.description.adminMetadata&.event
      return false if events.nil?

      true
    end

    def admin_creation_date?
      # check for existing cocina adminMetadata event for creation date
      events = cocina_model.description.adminMetadata&.event
      events.find { |event| event.type == 'creation' }
      events.any?
    end

    def access
      access_nodes = data_id_node.xpath(
        'gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString', NS
      )
      return unless access_nodes.any?

      { accessContact: access_nodes.map do |node|
                         { value: node.text, type: 'email', displayLabel: 'Contact' }
                       end }
    end

    def rootdir
      @rootdir ||= GisRobotSuite.locate_druid_path(bare_druid, type: :stage)
    end

    def vector_file
      @vector_file ||= Dir.glob(["#{rootdir}/content/*.shp", "#{rootdir}/content/*.geojson"]).first
    end

    def vector_file_format
      if vector_file.end_with?('.shp')
        'Shapefile'
      elsif vector_file.end_with?('.geojson')
        'GeoJSON'
      else
        raise "generate-descriptive: #{bare_druid} cannot detect fileFormat: #{vector_file}"
      end
    end

    def raster?
      vector_file.nil?
    end

    def raster_file_format
      tif_file = Dir.glob("#{rootdir}/content/*.tif").first
      if tif_file.nil?
        metadata_xml_file = Dir.glob("#{rootdir}/content/*/metadata.xml").first
        raise "generate-descriptive: #{bare_druid} cannot detect fileFormat: #{rootdir}/content" if metadata_xml_file.nil?

        'ArcGRID'
      else
        'GeoTIFF'
      end
    end

    def geometry_type
      @geometry_type ||= if raster?
                           'Raster'
                         elsif geometry_type_ogrinfo =~ /^Line/
                           'LineString'
                         else
                           geometry_type_ogrinfo
                         end
    end

    def file_format
      @file_format ||= if raster?
                         raster_file_format
                       else
                         vector_file_format
                       end
    end

    # Reads the shapefile to determine geometry type
    #
    # @return [String] Point, Polygon, LineString as appropriate
    def geometry_type_ogrinfo
      @geometry_type_ogrinfo ||= find_geometry_type_ogrinfo
    end

    def find_geometry_type_ogrinfo
      ogrinfo_str = GisRobotSuite.run_system_command("#{Settings.gdal_path}ogrinfo -ro -so -al '#{vector_file}'", logger:)[:stdout_str]
      ogrinfo_str.each_line do |line|
        next unless line =~ /^Geometry:\s+(.*)\s*$/

        return Regexp.last_match(1).gsub('3D', '').gsub('Multi', '').strip
      end
    end

    # rubocop:disable Style/NumericPredicate
    # Convert DD.DD to DD MM SS.SS
    # e.g.,
    # * -109.758319 => 109°45ʹ29.9484ʺ
    # * 48.999336 => 48°59ʹ57.609ʺ
    E = 1
    private_constant :E
    QSEC = 'ʺ'
    private_constant :QSEC
    QMIN = 'ʹ'
    private_constant :QMIN
    QDEG = "\u00B0"
    private_constant :QDEG

    def dd2ddmmss_abs(value)
      value_abs = value.abs
      degrees = value_abs.floor
      minutes_float = ((value_abs - degrees) * 60)
      minutes = minutes_float.floor
      seconds = ((minutes_float - minutes) * 60).round
      if seconds >= 60
        minutes += 1
        seconds = 0
      end
      if minutes >= 60
        degrees += 1
        minutes = 0
      end
      "#{degrees}#{QDEG}" + (minutes > 0 ? "#{minutes}#{QMIN}" : '') + (seconds > 0 ? "#{seconds}#{QSEC}" : '')
    end

    # Convert to MARC 255 DD into DDMMSS
    # westernmost longitude, easternmost longitude, northernmost latitude, and southernmost latitude
    # e.g., -109.758319 -- -88.990844/48.999336 -- 29.423028
    def to_coordinates_ddmmss(native_values)
      west, east, north, south = native_values
      raise ArgumentError, "Out of bounds latitude: #{north} #{south}" unless north.between?(-90, 90) && south.between?(-90, 90)
      raise ArgumentError, "Out of bounds longitude: #{west} #{east}" unless west.between?(-180, 180) && east.between?(-180, 180)

      west = "#{west < 0 ? 'W' : 'E'} #{dd2ddmmss_abs(west)}"
      east = "#{east < 0 ? 'W' : 'E'} #{dd2ddmmss_abs(east)}"
      north = "#{north < 0 ? 'S' : 'N'} #{dd2ddmmss_abs(north)}"
      south = "#{south < 0 ? 'S' : 'N'} #{dd2ddmmss_abs(south)}"
      "#{west}--#{east}/#{north}--#{south}"
    end
    # rubocop:enable Style/NumericPredicate

    def valid_uri(uri)
      raise "Invalid uri: '#{uri}'" unless uri.match?(GOOD_URI)

      uri
    end
  end
end
