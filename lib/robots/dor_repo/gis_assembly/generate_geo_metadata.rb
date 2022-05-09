# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class GenerateGeoMetadata < Base
        def initialize
          super('gisAssemblyWF', 'generate-geo-metadata', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid = druid.delete_prefix('druid:')
          LyberCore::Log.debug "generate-geo-metadata working on #{druid}"

          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage

          # short-circuit if work is already done
          metadatadir = "#{rootdir}/metadata"
          ofn = "#{metadatadir}/geoMetadata.xml"
          if File.size?(ofn)
            LyberCore::Log.info "generate-geo-metadata: #{druid} already has geoMetadata: #{ofn}"
            return
          end

          iso19139_xml_file = Dir.glob("#{rootdir}/temp/**/*-iso19139.xml").first
          if iso19139_xml_file.nil?
            raise "generate-geo-metadata: #{druid} is missing ISO 19139 file"
          end

          LyberCore::Log.debug "generate-geo-metadata processing #{iso19139_xml_file}"
          iso19139_ng_xml = Nokogiri::XML(File.read(iso19139_xml_file))
          if iso19139_ng_xml.nil? || iso19139_ng_xml.root.nil?
            raise ArgumentError, "generate-geo-metadata: #{druid} cannot parse ISO 19139 in #{iso19139_xml_file}"
          end

          iso19110_xml_file = Dir.glob("#{rootdir}/temp/*-iso19110.xml").first
          unless iso19110_xml_file.nil?
            LyberCore::Log.debug "generate-geo-metadata processing #{iso19110_xml_file}"
            iso19110_ng_xml = Nokogiri::XML(File.read(iso19110_xml_file))
          end

          # create geoMetadata RDF XML file
          FileUtils.mkdir(metadatadir) unless File.directory?(metadatadir)
          xml = geo_metadata_rdf_xml(iso19139_ng_xml, iso19110_ng_xml, Settings.purl.url + "/#{druid}")
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
