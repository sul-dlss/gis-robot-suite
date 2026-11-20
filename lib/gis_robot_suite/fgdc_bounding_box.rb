# frozen_string_literal: true

module GisRobotSuite
  # Writes the BoundingBox computed from the data into an FGDC record's spatial domain,
  # idinfo/spdom/bounding, in place of the extent ArcGIS2FGDC.xsl copied from the ArcGIS metadata.
  class FgdcBoundingBox
    # In the order CSDGM gives them
    BOUNDS = { west: 'westbc', east: 'eastbc', north: 'northbc', south: 'southbc' }.freeze
    # What idinfo may hold before spdom, latest first
    BEFORE_SPDOM = %w[status timeperd descript citation].freeze
    private_constant :BOUNDS, :BEFORE_SPDOM

    # @param [String, Pathname] fgdc_file the document ArcgisMetadataTransformer produced
    # @param [BoundingBox] bounding_box
    # @return [Pathname] the FGDC document, rewritten in place
    def self.apply(fgdc_file, bounding_box:, logger: nil)
      new(fgdc_file, bounding_box:, logger:).apply
    end

    def initialize(fgdc_file, bounding_box:, logger: nil)
      @fgdc_file = Pathname(fgdc_file)
      @bounding_box = bounding_box
      @logger = logger
    end

    def apply
      logger&.info("writing bounding box #{bounding_box.to_h} into #{fgdc_file.basename}")
      bounding.xpath(BOUNDS.values.join('|')).each(&:remove)
      BOUNDS.reverse_each { |key, name| bounding.prepend_child(element(name, bounding_box.public_send(key).to_s)) }

      fgdc_file.write(fgdc_ng.to_xml(indent: 2))
      fgdc_file
    end

    private

    attr_reader :fgdc_file, :bounding_box, :logger

    # Reparsed without the transform's indentation so that the whole document reserializes consistently.
    def fgdc_ng
      @fgdc_ng ||= Nokogiri::XML(fgdc_file.read, &:noblanks)
    end

    def idinfo
      @idinfo ||= fgdc_ng.at_xpath('/metadata/idinfo') || raise("#{fgdc_file.basename} has no idinfo to state an extent in")
    end

    # The bounding coordinates come first in the spatial domain.
    def bounding
      @bounding ||= spdom.at_xpath('bounding') || spdom.prepend_child(element('bounding'))
    end

    def spdom
      @spdom ||= idinfo.at_xpath('spdom') || begin
        preceding = BEFORE_SPDOM.lazy.filter_map { |name| idinfo.at_xpath(name) }.first
        new_spdom = element('spdom')
        preceding ? preceding.add_next_sibling(new_spdom) : idinfo.prepend_child(new_spdom)
      end
    end

    def element(name, text = nil)
      Nokogiri::XML::Node.new(name, fgdc_ng).tap { |node| node.content = text if text }
    end
  end
end
