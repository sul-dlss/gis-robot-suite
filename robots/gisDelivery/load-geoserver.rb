ENV['RGEOSERVER_CONFIG'] ||= File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environments', ENV['ROBOT_ENVIRONMENT'] + "_rgeoserver.yml"))
require 'rgeoserver'
require 'druid-tools'
require 'mods'

# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisDelivery   # This is your workflow package name (using CamelCase)

      class LoadGeoserver # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 

        def initialize
          super('dor', 'gisDeliveryWF', 'load-geoserver', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "load-geoserver working on #{druid}"
          
          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage
          
          # determine whether we have a Shapefile/vector or Raster to load
          modsfn = File.join(rootdir, 'metadata', 'descMetadata.xml')
          raise RuntimeError, "Cannot locate MODS: #{modsfn}" unless File.exists?(modsfn)
          format = GisRobotSuite::determine_file_format_from_mods modsfn
          raise RuntimeError, "Cannot determine file format from MODS: #{modsfn}" if format.nil?
          
          # reproject based on file format information
          mimetype = format.split(/;/).first # nix mimetype flags
          case mimetype
          when 'image/tiff'
            layertype = 'GeoTIFF'
          when 'application/x-esri-shapefile'
            layertype = 'PostGIS'
          else
            raise RuntimeError, "Unknown format: #{format}"
          end

          # Obtain layer details
          layer = layer_from_druid druid, modsfn, (layertype == 'GeoTIFF')
          layer[(layertype == 'GeoTIFF'? 'raster' : 'vector')]['format'] = layertype
          puts layer

          # Connect to GeoServer
          LyberCore::Log.debug "Connecting to catalog..."
          catalog = RGeoServer::catalog
          LyberCore::Log.debug "Connected to #{catalog}"

          # Obtain a handle to the workspace and clean it up. 
          ws = RGeoServer::Workspace.new catalog, :name => 'druid'
          raise RuntimeError, "No such workspace: 'druid'" if ws.new?
          LyberCore::Log.debug "Workspace: #{ws.name} ready"

          if layer['vector'] && layer['vector']['format'] == 'PostGIS'
            create_vector(catalog, ws, layer['vector'])
          else
            raise NotImplementedError # XXX: load to geoserver registry
          end
        end
        
        
        # @return [Hash] selectively parsed MODS record to match RGeoServer requirements
        def layer_from_druid druid, modsfn, is_raster = false
          LyberCore::Log.debug "Processing #{druid}"

          mods = Mods::Record.new
          mods.from_str(File.read(modsfn))
  
          h = { 
            (is_raster ? 'raster' : 'vector') => {
              'druid' => druid,
              'title' => mods.full_titles.first,
              'abstract' => mods.term_values(:abstract).compact.join("\n"),
              'keywords' => [mods.term_values([:subject, 'topic']),
                             mods.term_values([:subject, 'geographic'])].flatten.compact.collect {|k| k.strip},
              'metadata_links' => [{
                'metadataType' => 'TC211',
                'content' => "http://purl.stanford.edu/#{druid}.iso19139"
              }]
            }
          }
          h
        end
        
        def create_vector(catalog, ws, layer, dsname = 'geoserver')
          %w{title abstract keywords metadata_links}.each do |i|
            raise ArgumentError, "Layer is missing #{i}" unless layer.include?(i) && !layer[i].empty?
          end
          
          ds = RGeoServer::DataStore.new catalog, :workspace => ws, :name => dsname
          LyberCore::Log.debug "DataStore: #{ws.name}/#{ds.name}"
          LyberCore::Log.debug ({:profile => ds.profile}).to_s
          raise RuntimeError, "Datastore #{ds.name} not found" if ds.new?
          
          ft = RGeoServer::FeatureType.new catalog, :workspace => ws, :data_store => ds, :name => layer['druid']
          ft.enabled = true
          ft.title = layer['title']
          ft.abstract = layer['abstract']  
          ft.keywords = [ft.keywords, layer['keywords']].flatten.compact.uniq
          ft.metadata_links = layer['metadata_links']

          # XXX: need "the_geom" field
          LyberCore::Log.debug "Creating FeatureType #{layer['druid']}: #{ft}" if ft.new?
          ft.save
        end
        
      end
    end
  end
end
