# frozen_string_literal: true

module GisRobotSuite
  # Writes the BoundingBox computed from the data into an ISO 19139 record, and reads it back.
  #
  # ArcGIS2ISO19139.xsl copies whatever boxes the ArcGIS metadata holds: the extent ArcGIS synced
  # from the data, which is the plain minimum and maximum longitude and so spans the world for data
  # either side of the antimeridian, and any extent authored in the original record. All of them are
  # replaced by one box, so that the record states the same extent as everything read from it.
  class Iso19139BoundingBox
    NS = {
      'gmd' => 'http://www.isotc211.org/2005/gmd',
      'gco' => 'http://www.isotc211.org/2005/gco'
    }.freeze
    # Not anchored at the root: some records come wrapped in rdf:RDF.
    IDENTIFICATION = '//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification'
    GEOGRAPHIC_ELEMENTS = "#{IDENTIFICATION}/gmd:extent/gmd:EX_Extent/gmd:geographicElement[gmd:EX_GeographicBoundingBox]".freeze
    # In the order EX_GeographicBoundingBox gives them
    BOUNDS = {
      west: 'westBoundLongitude',
      east: 'eastBoundLongitude',
      south: 'southBoundLatitude',
      north: 'northBoundLatitude'
    }.freeze
    private_constant :NS, :IDENTIFICATION, :GEOGRAPHIC_ELEMENTS, :BOUNDS

    # @param [String, Pathname] iso19139_file the document ArcgisMetadataTransformer produced
    # @param [BoundingBox] bounding_box
    # @return [Pathname] the ISO 19139 document, rewritten in place
    def self.apply(iso19139_file, bounding_box:, logger: nil)
      new(iso19139_file, bounding_box:, logger:).apply
    end

    # @param [Nokogiri::XML::Document] iso19139_ng
    # @return [BoundingBox]
    # @raise [RuntimeError] unless the record states exactly one box, as extract-iso19139-metadata writes
    def self.read(iso19139_ng)
      boxes = iso19139_ng.xpath("#{GEOGRAPHIC_ELEMENTS}/gmd:EX_GeographicBoundingBox", NS)
      unless boxes.one?
        raise "ISO 19139 states #{boxes.size} geographic bounding boxes rather than the one " \
              'extract-iso19139-metadata computes from the data'
      end

      BoundingBox.new(**BOUNDS.transform_values { |name| Float(boxes.first.at_xpath("gmd:#{name}/gco:Decimal", NS).text) })
    end

    def initialize(iso19139_file, bounding_box:, logger: nil)
      @iso19139_file = Pathname(iso19139_file)
      @bounding_box = bounding_box
      @logger = logger
    end

    def apply
      logger&.info("writing bounding box #{bounding_box.to_h} into #{iso19139_file.basename}")
      replaced = iso19139_ng.xpath(GEOGRAPHIC_ELEMENTS, NS)
      extent = replaced.first&.parent || new_extent
      replaced.each(&:remove)

      # EX_Extent holds its geographic elements after its description and before any temporal or
      # vertical ones.
      following = extent.at_xpath('gmd:temporalElement|gmd:verticalElement', NS)
      following ? following.add_previous_sibling(geographic_element) : extent.add_child(geographic_element)
      remove_empty_extents

      iso19139_file.write(iso19139_ng.to_xml(indent: 2))
      iso19139_file
    end

    private

    attr_reader :iso19139_file, :bounding_box, :logger

    # Reparsed without the transform's indentation so that the whole document reserializes
    # consistently, as Iso19139BandUnits does.
    def iso19139_ng
      @iso19139_ng ||= Nokogiri::XML(iso19139_file.read, &:noblanks)
    end

    def identification
      @identification ||= iso19139_ng.at_xpath(IDENTIFICATION, NS) ||
                          raise("#{iso19139_file.basename} has no MD_DataIdentification to state an extent in")
    end

    # For when the ArcGIS metadata had no box to copy. An extent of its own rather than one the record
    # already has, since those describe something else, e.g. the temporal extent's "publication date".
    # It goes last in MD_DataIdentification but for supplementalInformation, which follows it.
    def new_extent
      ex_extent = element('EX_Extent', gmd)
      extent = element('extent', gmd, ex_extent)
      supplemental = identification.at_xpath('gmd:supplementalInformation', NS)
      supplemental ? supplemental.add_previous_sibling(extent) : identification.add_child(extent)
      ex_extent
    end

    # ArcGIS writes each extent it holds as an EX_Extent of its own, so taking out the boxes can
    # leave some with nothing in them, which ISO 19139 does not allow.
    def remove_empty_extents
      identification.xpath('gmd:extent[gmd:EX_Extent[not(*)]]', NS).each(&:remove)
    end

    # extentTypeCode true states that the box includes the data, rather than excludes it.
    def geographic_element
      bounds = BOUNDS.map { |key, name| element(name, gmd, element('Decimal', gco, text: bounding_box.public_send(key).to_s)) }

      element('geographicElement', gmd,
              element('EX_GeographicBoundingBox', gmd,
                      element('extentTypeCode', gmd, element('Boolean', gco, text: 'true')),
                      *bounds))
    end

    def element(name, namespace, *children, text: nil)
      Nokogiri::XML::Node.new(name, iso19139_ng).tap do |node|
        node.namespace = namespace
        node.content = text if text
        children.each { |child| node.add_child(child) }
      end
    end

    def gmd
      identification.namespace
    end

    def gco
      @gco ||= iso19139_ng.root.namespace_definitions.find { |namespace| namespace.href == NS['gco'] } ||
               iso19139_ng.root.add_namespace_definition('gco', NS['gco'])
    end
  end
end
