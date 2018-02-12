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
          druid = GisRobotSuite.initialize_robot druid
          LyberCore::Log.debug "load-geoserver working on #{druid}"

          rootdir = GisRobotSuite.locate_druid_path druid, type: :workspace

          # determine whether we have a Shapefile/vector or Raster to load
          modsfn = File.join(rootdir, 'metadata', 'descMetadata.xml')
          fail "load-geoserver: #{druid} cannot locate MODS: #{modsfn}" unless File.size?(modsfn)
          format = GisRobotSuite.determine_file_format_from_mods modsfn
          fail "load-geoserver: #{druid} cannot determine file format from MODS" if format.nil?

          # reproject based on file format information
          if GisRobotSuite.vector?(format)
            layertype = 'PostGIS'
          elsif GisRobotSuite.raster?(format)
            layertype = 'GeoTIFF'
          else
            fail "load-geoserver: #{druid} unknown format: #{format}"
          end

          # Obtain layer details
          layer = layer_from_druid druid, modsfn, (layertype == 'GeoTIFF')
          layer[(layertype == 'GeoTIFF' ? 'raster' : 'vector')]['format'] = layertype

          # Connect to GeoServer
          geoserver_options = YAML.load(File.read(ENV['RGEOSERVER_CONFIG']))
          master_opts = geoserver_options[:geoserver_master]
          LyberCore::Log.debug "GeoServer options: #{geoserver_options}"
          LyberCore::Log.debug "Connecting to catalog (#{master_opts})..."
          catalog = RGeoServer.catalog master_opts
          LyberCore::Log.debug "Connected to #{catalog}"

          # Obtain a handle to the workspace and clean it up.
          ws = RGeoServer::Workspace.new catalog, name: 'druid'
          fail "load-geoserver: #{druid}: No such workspace: 'druid'" if ws.new?
          LyberCore::Log.debug "Workspace: #{ws.name} ready"

          if layer['vector'] && layer['vector']['format'] == 'PostGIS'
            create_vector(catalog, ws, layer['vector'])
          elsif layer['raster'] && layer['raster']['format'] == 'GeoTIFF'
            create_raster(catalog, ws, layer['raster'])
          else
            fail NotImplementedError, "load-geoserver: #{druid} has unknown layer format: #{layer}"
          end

          # Reload the slave catalog
          slave_opts = geoserver_options[:geoserver_slave]
          unless slave_opts.nil?
            LyberCore::Log.debug "Connecting to slave catalog (#{slave_opts})..."
            catalog = RGeoServer.catalog slave_opts, true
            LyberCore::Log.debug "Connected to #{catalog}... reloading catalog"
            catalog.reload
          end
        end

        # @return [Hash] selectively parsed MODS record to match RGeoServer requirements
        def layer_from_druid(druid, modsfn, is_raster = false)
          mods = Mods::Record.new
          mods.from_str(File.read(modsfn))

          h = {
            (is_raster ? 'raster' : 'vector') => {
              'druid' => druid,
              'title' => mods.full_titles.first,
              'abstract' => mods.term_values(:abstract).compact.join("\n"),
              'keywords' => [mods.term_values([:subject, 'topic']),
                             mods.term_values([:subject, 'geographic'])].flatten.compact.collect(&:strip)
            }
          }
          h
        end

        def create_vector(catalog, ws, layer, dsname = 'postgis_druid')
          druid = layer['druid']
          %w(title abstract keywords).each do |i|
            fail ArgumentError, "load-geoserver: #{druid} layer is missing #{i}" unless layer.include?(i) && !layer[i].empty?
          end

          LyberCore::Log.debug "Retrieving DataStore: #{ws.name}/#{dsname}"
          ds = RGeoServer::DataStore.new catalog, workspace: ws, name: dsname
          fail "load-geoserver: #{druid}: Datastore #{dsname} not found on #{catalog}" if ds.nil? || ds.new?

          ft = RGeoServer::FeatureType.new catalog, workspace: ws, data_store: ds, name: druid
          if ft.new?
            LyberCore::Log.debug "Creating FeatureType #{druid}"
          else
            LyberCore::Log.debug "Found existing FeatureType #{druid}"
          end
          ft.enabled = true
          ft.title = layer['title']
          ft.abstract = layer['abstract']
          ft.keywords = [ft.keywords, layer['keywords']].flatten.compact.uniq
          begin
            ft.save
          rescue RGeoServer::GeoServerInvalidRequest => e
            fail "load-geoserver: #{druid} cannot save FeatureType: #{e.message}"
          end
        end

        def create_raster(catalog, ws, layer)
          druid = layer['druid']
          %w(title abstract keywords).each do |i|
            fail ArgumentError, "load-geoserver: #{druid}: Layer is missing #{i}" unless layer.include?(i) && !layer[i].empty?
          end

          # create coverage store
          LyberCore::Log.debug "Retrieving CoverageStore: #{ws.name}/#{druid}"
          cs = RGeoServer::CoverageStore.new catalog, workspace: ws, name: druid
          if cs.new?
            LyberCore::Log.debug "Creating CoverageStore: #{ws.name}/#{cs.name}"
            cs.enabled = true
            cs.description = layer['title']
            cs.data_type = 'GeoTIFF'
            cs.url = "file:#{Dor::Config.geohydra.geotiff.dir}/#{druid}.tif"
            begin
              cs.save
            rescue RGeoServer::GeoServerInvalidRequest => e
              fail "load-geoserver: #{druid} cannot save CoverageStore: #{e.message}"
            end
          else
            LyberCore::Log.debug "load-geoserver:: #{druid} found existing CoverageStore: #{ws.name}/#{cs.name}"
            fail "load-geoserver: #{druid} found disabled CoverageStore" unless cs.enabled
          end

          # create or update coverage
          LyberCore::Log.debug "Retrieving Coverage: #{ws.name}/#{cs.name}/#{druid}"
          cv = RGeoServer::Coverage.new catalog, workspace: ws, coverage_store: cs, name: druid
          if cv.new?
            LyberCore::Log.debug "Creating Coverage #{druid}"
          else
            LyberCore::Log.debug "Found existing Coverage #{druid}"
          end
          cv.enabled = true
          cv.title = layer['title']
          cv.abstract = layer['abstract']
          cv.keywords = [cv.keywords, layer['keywords']].flatten.compact.uniq
          begin
            cv.save
          rescue RGeoServer::GeoServerInvalidRequest => e
            fail "load-geoserver: #{druid} cannot save Coverage: #{e.message}"
          end

          # determine raster style
          raster_style = 'raster_' + GisRobotSuite.determine_raster_style("#{Dor::Config.geohydra.geotiff.dir}/#{druid}.tif")
          LyberCore::Log.debug "load-geoserver: #{druid} determined raster style as '#{raster_style}'"

          # need to create a style if it's a min/max style
          if raster_style =~ /^raster_grayscale_(.+)_(.+)$/
            _min = Regexp.last_match(1).to_f.floor
            _max = Regexp.last_match(2).to_f.ceil
            if _max < 2**13 # custom SLD only works with relatively narrow bands
              # generate SLD definition
              raster_style = "raster_#{druid}"
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
                  <ColorMapEntry color='#000000' quantity='#{_min}' opacity='1'/>
                  <ColorMapEntry color='#FFFFFF' quantity='#{_max}' opacity='1'/>
                </ColorMap>
              </RasterSymbolizer>
            </Rule>
          </FeatureTypeStyle>
      </UserStyle>
    </UserLayer>
  </StyledLayerDescriptor>"
              puts sldtxt

              # create a style with the SLD definition
              style = RGeoServer::Style.new catalog, name: raster_style
              LyberCore::Log.debug "load-geoserver: #{druid} loaded style #{style.name}"
              if style.new?
                style.sld_doc = sldtxt
                LyberCore::Log.debug "load-geoserver: #{druid} saving new style #{style.name}"
                style.save
              end
            else
              raster_style = 'raster_grayband' # a simple band-oriented histogram adjusted style
              style = RGeoServer::Style.new catalog, name: raster_style
              fail "load-geoserver: #{druid} has missing style #{raster_style} on #{catalog}" if style.new?
            end
          else
            style = RGeoServer::Style.new catalog, name: raster_style
            fail "load-geoserver: #{druid} has missing style #{raster_style} on #{catalog}" if style.new?
          end

          # fetch layer to load raster style - it's created when the coverage is created via REST API
          lyr = RGeoServer::Layer.new catalog, workspace: ws, name: druid
          if lyr.new?
            fail "load-geoserver: Layer #{druid} is missing for coverage #{ws.name}/#{cs.name}/#{druid}"
          end
          if lyr.default_style != style.name
            lyr.default_style = style.name
            LyberCore::Log.debug "load-geoserver: #{druid} updating #{lyr.name} with default style #{style.name}"
            begin
              lyr.save
            rescue RGeoServer::GeoServerInvalidRequest => e
              fail "load-geoserver: #{druid} cannot save Layer: #{e.message}"
            end
          end
        end
      end
    end
  end
end
