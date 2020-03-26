# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisAssembly   # This is your workflow package name (using CamelCase)
      class LoadGeoMetadata # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot

        def initialize
          super('dor', 'gisAssemblyWF', 'load-geo-metadata', check_queued_status: true) # init LyberCore::Robot
        end

        def load(item, geoMetadataXML)
          # load the geoMetadata datastream
          if item.datastreams['geoMetadata'].nil?
            item.add_datastream(Dor::GeoMetadataDS.new(item, 'geoMetadata'))
          end
          item.datastreams['geoMetadata'].content = geoMetadataXML
        end

        TAG_GIS = 'Dataset : GIS'
        def tag(item)
          current_tags = tags_client(item.pid).list
          return if current_tags.include?(TAG_GIS)

          tags_client.create(tags: [TAG_GIS])
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid = GisRobotSuite.initialize_robot druid
          LyberCore::Log.debug "load-geo-metadata: #{druid} working"

          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage

          # Locate geoMetadata datastream
          fn = File.join(rootdir, 'metadata', 'geoMetadata.xml')
          fail "load-geo-metadata: #{druid} cannot locate geoMetadata: #{fn}" unless File.size?(fn)

          # Load geoMetadata into DOR Item
          item = Dor::Item.find("druid:#{druid}")
          fail "load-geo-metadata: #{druid} cannot find in DOR" if item.nil?
          load item, Nokogiri::XML(File.read(fn)).to_xml
          tag item
          LyberCore::Log.debug "load-geo-metadata: #{druid} saving to DOR"
          item.save
        end

        private

        def tags_client(pid)
          Dor::Services::Client.object(pid).administrative_tags
        end
      end
    end
  end
end
