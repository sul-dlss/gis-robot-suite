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

          # short-circuit if work is already done
          metadatadir = "#{rootdir}/metadata"
          ofn = "#{metadatadir}/geoMetadata.xml"
          if File.size?(ofn)
            logger.info "generate-geo-metadata: #{bare_druid} already has geoMetadata: #{ofn}"
            return
          end

          iso19139_xml_file = Dir.glob("#{rootdir}/temp/**/*-iso19139.xml").first
          raise "generate-geo-metadata: #{bare_druid} is missing ISO 19139 file" if iso19139_xml_file.nil?

          logger.debug "generate-geo-metadata processing #{iso19139_xml_file}"
          iso19139_ng_xml = Nokogiri::XML(File.read(iso19139_xml_file))
          # rubocop:disable Style/IfUnlessModifier
          # due to line length
          if iso19139_ng_xml.nil? || iso19139_ng_xml.root.nil?
            raise ArgumentError, "generate-geo-metadata: #{bare_druid} cannot parse ISO 19139 in #{iso19139_xml_file}"
          end
          # rubocop:enable Style/IfUnlessModifier

          iso19110_xml_file = Dir.glob("#{rootdir}/temp/*-iso19110.xml").first
          unless iso19110_xml_file.nil?
            logger.debug "generate-geo-metadata processing #{iso19110_xml_file}"
            iso19110_ng_xml = Nokogiri::XML(File.read(iso19110_xml_file))
          end

          # create geoMetadata RDF XML file
          FileUtils.mkdir(metadatadir) unless File.directory?(metadatadir)
          xml = geo_metadata_rdf_xml(iso19139_ng_xml, iso19110_ng_xml, Settings.purl.url + "/#{bare_druid}")
          File.open(ofn, 'wb') { |f| f << xml.to_xml(indent: 2) }
        end

        # Converts a ISO 19139 into RDF-bundled document geoMetadata XML file
        # @param [Nokogiri::XML::Document] iso19139_ng_xml ISO 19193 MD_Metadata node
        # @param [Nokogiri::XML::Document] iso19110_ng_xml ISO 19110 feature catalog
        # @param [String] purl The unique purl url
        # @return [Nokogiri::XML::Document] the geoMetadata file with RDF as XML
        def geo_metadata_rdf_xml(iso19139_ng_xml, iso19110_ng_xml, purl)
          raise ArgumentError, 'generate-geo-metadata: PURL is required' if purl.nil?
          raise ArgumentError, 'generate-geo-metadata: ISO 19139 is required' if iso19139_ng_xml.nil? || iso19139_ng_xml.root.nil?

          Nokogiri::XML("
            <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\">
              <rdf:Description rdf:about=\"#{purl}\">
                #{iso19139_ng_xml.root}
              </rdf:Description>
              <rdf:Description rdf:about=\"#{purl}\">
                #{iso19110_ng_xml.nil? ? '' : iso19110_ng_xml.root.to_s}
              </rdf:Description>
            </rdf:RDF>")
        end
      end
    end
  end
end
