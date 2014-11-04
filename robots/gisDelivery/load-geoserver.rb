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
          
          rootdir = GisRobotSuite.locate_druid_path druid, type: :workspace
          
          # determine whether we have a Shapefile/vector or Raster to load
          modsfn = File.join(rootdir, 'metadata', 'descMetadata.xml')
          raise RuntimeError, "load-geoserver: #{druid} cannot locate MODS: #{modsfn}" unless File.exists?(modsfn)
          format = GisRobotSuite::determine_file_format_from_mods modsfn
          raise RuntimeError, "load-geoserver: #{druid} cannot determine file format from MODS" if format.nil?
          
          # reproject based on file format information
          mimetype = format.split(/;/).first # nix mimetype flags
          case mimetype
          when GisRobotSuite.determine_mimetype(:raster)
            layertype = 'GeoTIFF'
          when GisRobotSuite.determine_mimetype(:vector)
            layertype = 'PostGIS'
          else
            raise RuntimeError, "load-geoserver: #{druid} has unknown format: #{format}"
          end

          # Obtain layer details
          layer = layer_from_druid druid, modsfn, (layertype == 'GeoTIFF')
          layer[(layertype == 'GeoTIFF'? 'raster' : 'vector')]['format'] = layertype

          # Connect to GeoServer
          LyberCore::Log.debug "Connecting to catalog..."
          catalog = RGeoServer::catalog
          LyberCore::Log.debug "Connected to #{catalog}"

          # Obtain a handle to the workspace and clean it up. 
          ws = RGeoServer::Workspace.new catalog, :name => 'druid'
          raise RuntimeError, "load-geoserver: #{druid}: No such workspace: 'druid'" if ws.new?
          LyberCore::Log.debug "Workspace: #{ws.name} ready"

          if layer['vector'] && layer['vector']['format'] == 'PostGIS'
            create_vector(catalog, ws, layer['vector'])
          elsif layer['raster'] && layer['raster']['format'] == 'GeoTIFF'
            create_raster(catalog, ws, layer['raster'])
          else
            raise NotImplementedError, "load-geoserver: #{druid} has unknown layer format: #{layer}"
          end
        end
        
        
        # @return [Hash] selectively parsed MODS record to match RGeoServer requirements
        def layer_from_druid druid, modsfn, is_raster = false
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
        
        def create_vector(catalog, ws, layer, dsname = 'postgis_druid')
          druid = layer['druid']
          %w{title abstract keywords metadata_links}.each do |i|
            raise ArgumentError, "load-geoserver: #{druid} layer is missing #{i}" unless layer.include?(i) && !layer[i].empty?
          end
          
          LyberCore::Log.debug "Retrieving DataStore: #{ws.name}/#{dsname}"
          ds = RGeoServer::DataStore.new catalog, :workspace => ws, :name => dsname
          raise RuntimeError, "load-geoserver: #{druid}: Datastore #{dsname} not found" if ds.nil? || ds.new?
          
          ft = RGeoServer::FeatureType.new catalog, :workspace => ws, :data_store => ds, :name => druid
          if ft.new?
            LyberCore::Log.debug "Creating FeatureType #{layer['druid']}"
            ft.enabled = true
            ft.title = layer['title']
            ft.abstract = layer['abstract']  
            ft.keywords = [ft.keywords, layer['keywords']].flatten.compact.uniq
            ft.metadata_links = layer['metadata_links']
            ft.save
          else
            raise RuntimeError, "load-geoserver: FeatureType #{druid} already exists in #{ds.name}" 
          end
        end

        def create_raster(catalog, ws, layer)
          druid = layer['druid']
          %w{title abstract keywords metadata_links}.each do |i|
            raise ArgumentError, "load-geoserver: #{druid}: Layer is missing #{i}" unless layer.include?(i) && !layer[i].empty?
          end
          
          # create coverage store
          LyberCore::Log.debug "Retrieving CoverageStore: #{ws.name}/#{druid}"
          cs = RGeoServer::CoverageStore.new catalog, :workspace => ws, :name => druid
          if cs.new?
            LyberCore::Log.debug "Creating CoverageStore: #{ws.name}/#{cs.name}"
            cs.enabled = true
            cs.description = layer['title']
            cs.data_type = 'GeoTIFF'
            cs.url = "file:#{Dor::Config.geohydra.geotiff.dir}/#{druid}.tif" 
            cs.save
          else
            LyberCore::Log.debug "Found existing CoverageStore: #{ws.name}/#{cs.name}"
          end
          
          # create or update coverage
          LyberCore::Log.debug "Retrieving Coverage: #{ws.name}/#{cs.name}/#{druid}"
          cv = RGeoServer::Coverage.new catalog, :workspace => ws, :coverage_store => cs, :name => druid
          if cv.new?
            LyberCore::Log.debug "Creating Coverage #{druid}"
          else
            LyberCore::Log.debug "Found existing Coverage #{druid}"
          end
          cv.enabled = true
          cv.title = layer['title']
          cv.abstract = layer['abstract']  
          cv.keywords = [cv.keywords, layer['keywords']].flatten.compact.uniq
          cv.metadata_links = layer['metadata_links']
          cv.save

          # determine raster style
          raster_style = GisRobotSuite.determine_raster_style("#{Dor::Config.geohydra.geotiff.dir}/#{druid}.tif")
          
          # need to create a style if it's a min/max style
          if raster_style =~ /^grayscale_(.+)_(.+)$/
            # generate SLD definition
            sldtxt = "
<StyledLayerDescriptor xmlns='http://www.opengis.net/sld' 
                       xmlns:ogc='http://www.opengis.net/ogc' 
                       xmlns:xlink='http://www.w3.org/1999/xlink' 
                       xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' 
                       xsi:schemaLocation='http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd' 
                       version='1.0.0'>
  <UserLayer>
    <Name>raster_layer</Name>
      <UserStyle>
        <FeatureTypeStyle>
          <Rule>
            <RasterSymbolizer>
              <ColorMap>
                <ColorMapEntry color='#000000' quantity='#{$1.to_f.floor}' opacity='1'/>
                <ColorMapEntry color='#FFFFFF' quantity='#{$2.to_f.ceil}' opacity='1'/>
              </ColorMap>
            </RasterSymbolizer>
          </Rule>
        </FeatureTypeStyle>
    </UserStyle>
  </UserLayer>
</StyledLayerDescriptor>"
            File.open("#{Dor::Config.geohydra.geoserver.styledir}/#{raster_style}.sld", 'w') {|f| f << sldtxt }
            
            # create a style with the SLD definition
            style = RGeoServer::Style.new catalog, :name => style
            if style.new?
              style.filename = "#{raster_style}.sld"
              style.save
            end
          end

          # fetch layer to load raster style - it's created when the coverage is created via REST API
          lyr = RGeoServer::Layer.new catalog, :workspace => ws, :name => druid
          if lyr.new?
            raise RuntimeError, "load-geoserver: Layer #{druid} is missing for coverage #{ws.name}/#{cs.name}/#{druid}"
          end
          lyr.default_style = style
          lyr.save
        end
        
      end
    end
  end
end
