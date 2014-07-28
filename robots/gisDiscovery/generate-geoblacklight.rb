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

        def convert_mods2geoblacklight(rootdir, druid)
          flags = {
            :geoserver => Dor::Config.geoserver.url,
            :purl => Dor::Config.purl.url + "/" + druid.gsub(/^druid:/, '')
          }

          # GeoBlacklight Solr document from descMetadataDS
          ifn = File.join(rootdir, 'metadata', 'descMetadata.xml')
          ofn = File.join(rootdir, 'metadata', 'geoblacklight.xml')
          FileUtils.rm_f(ofn) if File.exist?(ofn)
          cmd = ['xsltproc',
                  "--stringparam geoserver_root '#{flags[:geoserver]}'",
                  "--stringparam purl '#{flags[:purl]}'",
                  "--stringparam now '#{Time.now.utc.to_datetime.rfc3339}'",
                  "--output '#{ofn}'",
                  "'#{File.expand_path(File.dirname(__FILE__) + '../../../schema/lib/xslt/mods2geoblacklight.xsl')}'",
                  "'#{ifn}'"
                  ].join(' ')
          system cmd
        end
        
        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "generate-geoblacklight working on #{druid}"
          
          rootdir = GisRobotSuite.druid_path druid, type: :stage
          raise ArgumentError, "Missing #{rootdir}" unless File.directory?(rootdir)
          
          convert_mods2geoblacklight rootdir, druid

        end
      end

    end
  end
end
