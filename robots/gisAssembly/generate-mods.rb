require 'rgeo'
require 'rgeo/shapefile'

# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisAssembly   # This is your workflow package name (using CamelCase)

      class GenerateMods # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 

        def initialize
          super('dor', 'gisAssemblyWF', 'generate-mods', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "generate-mods working on #{druid}"

          rootdir = GisRobotSuite.druid_path druid, type: :stage
          raise ArgumentError, "Missing #{rootdir}" unless File.directory?(rootdir)

          fn = File.join(rootdir, 'metadata', 'geoMetadata.xml')
          geoMetadataDS = Dor::GeoMetadataDS.from_xml File.read(fn)
          geoMetadataDS.zipName = 'data.zip'
          geoMetadataDS.purl = Dor::Config.purl.url + "/#{druid.gsub(/^druid:/, '')}"

          fn = Dir.glob("#{rootdir}/temp/*.shp").first
          unless fn.nil?
            geoMetadataDS.geometryType = geometry_type(fn)
          else
            geoMetadataDS.geometryType = 'Raster'
          end

          File.open(ile.join(rootdir, 'metadata', 'descMetadata.xml'), 'wb') do |f| 
            f << geoMetadataDS.to_mods.to_xml(:index => 2) 
          end
          
        end
      end

      # Reads the shapefile to determine geometry type
      #
      # @return [String] Point, Polygon, LineString as appropriate
      def geometry_type(shp_filename)
        RGeo::Shapefile::Reader.open(shp_filename) do |shp|
          shp.each do |record|
            return record.geometry.geometry_type.to_s.gsub(/^Multi/,'')
          end
        end
        nil     
      end
      
    end
  end
end
