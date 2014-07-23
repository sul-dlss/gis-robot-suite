# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisAssembly   # This is your workflow package name (using CamelCase)

      class GenerateGeoMetadata # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 

        def initialize
          super('dor', 'gisAssemblyWF', 'generate-geo-metadata', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "generate-geo-metadata working on #{druid}"

          rootdir = Dor::Config.geohydra.stage
          raise ArgumentError, "Missing #{rootdir}" unless File.directory?(rootdir)
          
          
          fn = Dir.glob("#{rootdir}/#{druid}/temp/*-iso19139.xml").first
          if fn.nil?
            raise RuntimeError, "Missing ISO19139 file for #{druid}"
          end
          
          LyberCore::Log.debug "generate-geo-metadata processing #{fn}"
          isoXml = Nokogiri::XML(File.read(fn))
          if isoXml.nil? or isoXml.root.nil?
            raise ArgumentError, "Empty ISO 19139" 
          end

          fn = Dir.glob("#{rootdir}/#{druid}/temp/*-iso19110.xml").first
          unless fn.nil?
            LyberCore::Log.debug "generate-geo-metadata processing #{fn}"
            fcXml = Nokogiri::XML(File.read(fn))
          end

          # GeoMetadataDS
          ofn = "#{rootdir}/#{druid}/metadata/geoMetadata.xml"
          xml = to_geoMetadataDS(isoXml, fcXml, Dor::Config.purl.url + "/#{druid}") 
          File.open(ofn, 'wb') {|f| f << xml.to_xml(:indent => 2) }  
        end
        
        # Converts a ISO 19139 into RDF-bundled document geoMetadataDS
        # @param [Nokogiri::XML::Document] isoXml ISO 19193 MD_Metadata node
        # @param [Nokogiri::XML::Document] fcXml ISO 19193 feature catalog
        # @param [String] purl The unique purl url
        # @return [Nokogiri::XML::Document] the geoMetadataDS with RDF
        def to_geoMetadataDS isoXml, fcXml, purl
          raise ArgumentError, "PURL is required" if flags['purl'].nil?
          raise ArgumentError, "ISO 19139 is required" if isoXml.nil? or isoXml.root.nil?
          Nokogiri::XML("
            <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\">
              <rdf:Description rdf:about=\"#{purl}\">
                #{isoXml.root.to_s}
              </rdf:Description>
              <rdf:Description rdf:about=\"#{purl}\">
                #{fcXml.nil?? '' : fcXml.root.to_s}
              </rdf:Description>
            </rdf:RDF>"
            )
        end
        
      end

    end
  end
end
