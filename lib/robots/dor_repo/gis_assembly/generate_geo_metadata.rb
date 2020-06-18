# frozen_string_literal: true

# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisAssembly   # This is your workflow package name (using CamelCase)
      class GenerateGeoMetadata < Base
        def initialize
          super('gisAssemblyWF', 'generate-geo-metadata', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid = GisRobotSuite.initialize_robot druid
          LyberCore::Log.debug "generate-geo-metadata working on #{druid}"

          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage

          # short-circuit if work is already done
          metadatadir = "#{rootdir}/metadata"
          ofn = "#{metadatadir}/geoMetadata.xml"
          if File.size?(ofn)
            LyberCore::Log.info "generate-geo-metadata: #{druid} already has geoMetadata: #{ofn}"
            return
          end

          fn = Dir.glob("#{rootdir}/temp/**/*-iso19139.xml").first
          if fn.nil?
            fail "generate-geo-metadata: #{druid} is missing ISO 19139 file"
          end

          LyberCore::Log.debug "generate-geo-metadata processing #{fn}"
          isoXml = Nokogiri::XML(File.read(fn))
          if isoXml.nil? || isoXml.root.nil?
            fail ArgumentError, "generate-geo-metadata: #{druid} cannot parse ISO 19139 in #{fn}"
          end

          fn = Dir.glob("#{rootdir}/temp/*-iso19110.xml").first
          unless fn.nil?
            LyberCore::Log.debug "generate-geo-metadata processing #{fn}"
            fcXml = Nokogiri::XML(File.read(fn))
          end

          # GeoMetadataDS
          FileUtils.mkdir(metadatadir) unless File.directory?(metadatadir)
          xml = to_geoMetadataDS(isoXml, fcXml, Settings.purl.url + "/#{druid}")
          File.open(ofn, 'wb') { |f| f << xml.to_xml(indent: 2) }
        end

        # Converts a ISO 19139 into RDF-bundled document geoMetadataDS
        # @param [Nokogiri::XML::Document] isoXml ISO 19193 MD_Metadata node
        # @param [Nokogiri::XML::Document] fcXml ISO 19193 feature catalog
        # @param [String] purl The unique purl url
        # @return [Nokogiri::XML::Document] the geoMetadataDS with RDF
        def to_geoMetadataDS(isoXml, fcXml, purl)
          fail ArgumentError, 'generate-geo-metadata: PURL is required' if purl.nil?
          fail ArgumentError, 'generate-geo-metadata: ISO 19139 is required' if isoXml.nil? || isoXml.root.nil?

          Nokogiri::XML("
            <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\">
              <rdf:Description rdf:about=\"#{purl}\">
                #{isoXml.root}
              </rdf:Description>
              <rdf:Description rdf:about=\"#{purl}\">
                #{fcXml.nil? ? '' : fcXml.root.to_s}
              </rdf:Description>
            </rdf:RDF>"
                       )
        end
      end
    end
  end
end
