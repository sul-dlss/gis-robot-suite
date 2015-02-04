require 'date' # for rfc3339

# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisDiscovery   # This is your workflow package name (using CamelCase)

      class GenerateGeoblacklight # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 

        def initialize
          super('dor', 'gisDiscoveryWF', 'generate-geoblacklight', check_queued_status: true) # init LyberCore::Robot
        end

        def convert_mods2geoblacklight(rootdir, druid, rights = 'Restricted', rightsMetadata = nil)
          flags = {
            :geoserver => rights == 'Restricted' ? 
                Dor::Config.geohydra.geoserver.url_restricted : 
                Dor::Config.geohydra.geoserver.url_public,
            :stacks => Dor::Config.stacks.url,
            :purl => Dor::Config.purl.url + "/" + druid.gsub(/^druid:/, '')
          }

          # GeoBlacklight Solr document from descMetadataDS
          ifn = File.join(rootdir, 'metadata', 'descMetadata.xml')
          raise RuntimeError, "generate-geoblacklight: #{druid} cannot find MODS metadata: #{ifn}" unless File.size?(ifn)
          
          ofn = File.join(rootdir, 'metadata', 'geoblacklight.xml')
                    
          # run XSLT
          xslfn = "#{File.expand_path(File.dirname(__FILE__) + '../../../schema/lib/xslt/mods2geoblacklight.xsl')}"
          cmd = ['xsltproc',
                  "--stringparam geoserver_root '#{flags[:geoserver]}'",
                  "--stringparam wxs_geoserver_root '#{flags[:geoserver]}'",
                  "--stringparam stacks_root '#{flags[:stacks]}'",
                  "--stringparam now '#{Time.now.utc.strftime('%FT%TZ')}'",
                  "--stringparam rights '#{rights}'",
                  "--stringparam rights_metadata '#{rightsMetadata}'",
                  "--output '#{ofn}'",
                  "'#{xslfn}'",
                  "'#{ifn}'"
                  ].join(' ')
          system cmd
          raise RuntimeError, "generate-geoblacklight: #{druid} cannot transform MODS into GeoBlacklight schema" unless File.size?(ofn)
        end
        
        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid = GisRobotSuite.initialize_robot druid
          LyberCore::Log.debug "generate-geoblacklight working on #{druid}"
          
          rootdir = GisRobotSuite.locate_druid_path druid, type: :workspace
          
          # GeoBlacklight Solr document from descMetadataDS
          ifn = File.join(rootdir, 'metadata', 'descMetadata.xml')
          raise RuntimeError, "generate-geoblacklight: #{druid} cannot find MODS metadata: #{ifn}" unless File.size?(ifn)
          
          # Always overwrite any existing schema data because either MODS or the Rights may change.
          ofn = File.join(rootdir, 'metadata', 'geoblacklight.xml')
          if File.size?(ofn)
            LyberCore::Log.debug "generate-geoblacklight: #{druid} regenerating GeoBlacklight metadata"
            FileUtils.rm_f(ofn)
          end
          
          rights = 'Restricted'
          rightsMetadata = nil
          begin
            item = Dor::Item.find("druid:#{druid}")
            xml = item.rightsMetadata.ng_xml
            rightsMetadata = xml.to_xml(indent: 0)
            if xml.search('//rightsMetadata/access[@type=\'read\']/machine/world').length > 0
              rights = 'Public'
            end
          rescue ActiveFedora::ObjectNotFoundError => e
            LyberCore::Log.warn "generate-geoblacklight: #{druid} cannot determine rights, item not found in DOR"
          end
          
          convert_mods2geoblacklight rootdir, druid, rights, rightsMetadata
        end
      end
    end
  end
end
