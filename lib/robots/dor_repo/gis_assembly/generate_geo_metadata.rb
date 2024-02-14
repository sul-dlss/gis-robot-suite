# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class GenerateGeoMetadata < Base
        def initialize
          super('gisAssemblyWF', 'generate-geo-metadata')
        end

        def perform_work
          logger.debug "generate-geo-metadata working on #{bare_druid}"

          rootdir = GisRobotSuite.locate_druid_path bare_druid, type: :stage

          iso19139_xml_file = Dir.glob("#{rootdir}/temp/**/*-iso19139.xml").first
          raise "generate-geo-metadata: #{bare_druid} is missing ISO 19139 file" if iso19139_xml_file.nil?

          logger.debug "generate-geo-metadata processing #{iso19139_xml_file}"
          iso19139_ng_xml = Nokogiri::XML(File.read(iso19139_xml_file))
          raise ArgumentError, "generate-geo-metadata: #{bare_druid} cannot parse ISO 19139 in #{iso19139_xml_file}" if iso19139_ng_xml.nil? || iso19139_ng_xml.root.nil?

          iso19110_xml_file = Dir.glob("#{rootdir}/temp/*-iso19110.xml").first
          unless iso19110_xml_file.nil?
            logger.debug "generate-geo-metadata processing #{iso19110_xml_file}"
            iso19110_ng_xml = Nokogiri::XML(File.read(iso19110_xml_file))
          end

          # create geo metadata RDF XML
          geographic_xml = geo_metadata_rdf_xml(iso19139_ng_xml, iso19110_ng_xml, Settings.purl.url + "/#{bare_druid}")

          updated = cocina_object.new(
            type: Cocina::Models::ObjectType.geo,
            geographic: { iso19139: geographic_xml }
          )
          # Load geo metadata into DOR
          object_client.update(params: updated)
        end

        # Converts a ISO 19139 into RDF-bundled document XML
        # @param [Nokogiri::XML::Document] iso19139_ng_xml ISO 19193 MD_Metadata node
        # @param [Nokogiri::XML::Document] iso19110_ng_xml ISO 19110 feature catalog
        # @param [String] purl The unique purl url
        # @return [Nokogiri::XML::Document] the geo metadata with RDF as XML
        def geo_metadata_rdf_xml(iso19139_ng_xml, iso19110_ng_xml, purl)
          raise ArgumentError, 'generate-geo-metadata: PURL is required' if purl.nil?
          raise ArgumentError, 'generate-geo-metadata: ISO 19139 is required' if iso19139_ng_xml.nil? || iso19139_ng_xml.root.nil?

          geo_metadata = Nokogiri::XML("
            <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\">
              <rdf:Description rdf:about=\"#{purl}\">
                #{iso19139_ng_xml.root}
              </rdf:Description>
              <rdf:Description rdf:about=\"#{purl}\">
                #{iso19110_ng_xml.nil? ? '' : iso19110_ng_xml.root.to_s}
              </rdf:Description>
            </rdf:RDF>")
          geo_metadata.to_xml(indent: 2, encoding: 'UTF-8')
        end
      end
    end
  end
end
