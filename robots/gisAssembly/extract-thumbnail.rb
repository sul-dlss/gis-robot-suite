require 'base64'

# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisAssembly   # This is your workflow package name (using CamelCase)

      class ExtractThumbnail # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 

        def initialize
          super('dor', 'gisAssemblyWF', 'extract-thumbnail', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "extract-thumbnail working on #{druid}"
          extract_thumbnail druid
        end
        
        # Extracts an inline thumbnail from the ESRI ArcCatalog metadata format
        # @raise [ArgumentError] if cannot find a thumbnail
        def extract_thumbnail druid
          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage

          # @param [String] fn the metadata
          # @param [String] thumbnail_fn the file into which to write JPEG image
          # @param [String] property_type is the EsriPropertyType to select 
          fn = GisRobotSuite.locate_esri_metadata "#{rootdir}/temp"         
          raise RuntimeError, "Missing ESRI metadata files in #{rootdir}/temp" if fn.nil?
          
          content_dir = File.join(rootdir, 'content')
          FileUtils.mkdir(content_dir) unless File.directory?(content_dir)
          thumbnail_fn = File.join(content_dir, 'preview.jpg')
          property_type = 'PictureX'
          
          doc = Nokogiri::XML(File.read(fn))
          doc.xpath('//Binary/Thumbnail/Data').each do |node|
            if property_type.nil? or node['EsriPropertyType'] == property_type
              image = Base64.decode64(node.text)
              File.open(thumbnail_fn, 'wb') {|f| f << image }
              return
            end
          end
          raise ArgumentError, "No thumbnail embedded within #{fn}"
        end
      end

    end
  end
end
