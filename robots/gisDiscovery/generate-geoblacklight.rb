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

        def convert_mods2geoblacklight(rootdir, druid, rights = 'Restricted')
          flags = {
            :geoserver => Dor::Config.geoserver.url,
            :stacks => Dor::Config.stacks.url,
            :purl => Dor::Config.purl.url + "/" + druid.gsub(/^druid:/, '')
          }

          # GeoBlacklight Solr document from descMetadataDS
          ifn = File.join(rootdir, 'metadata', 'descMetadata.xml')
          raise RuntimeError, "Cannot find MODS metadata: #{ifn}" unless File.exists?(ifn)
          
          ofn = File.join(rootdir, 'metadata', 'geoblacklight.xml')
          FileUtils.rm_f(ofn) if File.exist?(ofn)
          
          # run XSLT
          xslfn = "#{File.expand_path(File.dirname(__FILE__) + '../../../schema/lib/xslt/mods2geoblacklight.xsl')}"
          cmd = ['xsltproc',
                  "--stringparam geoserver_root '#{flags[:geoserver]}'",
                  "--stringparam stacks_root '#{flags[:stacks]}'",
                  "--stringparam purl '#{flags[:purl]}'",
                  "--stringparam now '#{Time.now.utc.to_datetime.rfc3339}'",
                  "--stringparam rights '#{rights}'",
                  "--output '#{ofn}'",
                  "'#{xslfn}'",
                  "'#{ifn}'"
                  ].join(' ')
          system cmd
          raise RuntimeError, "Cannot transform MODS into GeoBlacklight schema" unless File.exists?(ofn)
        end
        
        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "generate-geoblacklight working on #{druid}"
          
          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage
          
          rights = 'Restricted'
          begin
            item = Dor::Item.find("druid:#{druid}")
            if item.rightsMetadata.ng_xml.search('//rightsMetadata/access[@type=\'read\']/machine/world').length == 1
              rights = 'Public'
            end
          rescue ActiveFedora::ObjectNotFoundError => e
            LyberCore::Log.warn "#{druid} not found in DOR"
          end
          
          convert_mods2geoblacklight rootdir, druid, rights
        end
      end
    end
  end
end
