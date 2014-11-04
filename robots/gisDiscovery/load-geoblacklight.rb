require 'rsolr'

# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisDiscovery   # This is your workflow package name (using CamelCase)

      class LoadGeoblacklight # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 

        def initialize
          super('dor', 'gisDiscoveryWF', 'load-geoblacklight', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "load-geoblacklight working on #{druid}"

          rootdir = GisRobotSuite.locate_druid_path druid, type: :workspace
          xmlfn = File.join(rootdir, 'metadata', 'geoblacklight.xml')
          raise RuntimeError, "load-geoblacklight: #{druid} cannot locate GeoBlacklight metadata: #{xmlfn}" unless File.exists?(xmlfn)
          
          LyberCore::Log.debug "Parsing #{xmlfn}"
          doc = Nokogiri::XML(File.read(xmlfn))
          raise RuntimeError, "load-geoblacklight: #{druid} cannot parse GeoBlacklight metadata" if doc.nil?
          
          url = File.join(Dor::Config.geohydra.solr.url, Dor::Config.geohydra.solr.collection)
          LyberCore::Log.debug "Connecting to #{url}"
          solr = RSolr.connect :url => url
          solr.update :data => doc.to_xml
          solr.commit
          LyberCore::Log.info "load-geoblacklight: #{druid} updated in #{url}"
        end
      end

    end
  end
end
