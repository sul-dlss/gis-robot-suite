# frozen_string_literal: true

require 'druid-tools'
require 'mods'

# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisDelivery   # This is your workflow package name (using CamelCase)
      class LoadGeoserver < Base
        def initialize
          super('gisDeliveryWF', 'load-geoserver', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid = druid.delete_prefix('druid:')
          LyberCore::Log.debug "load-geoserver working on #{druid}"

          rootdir = GisRobotSuite.locate_druid_path druid, type: :workspace

          # determine whether we have a Shapefile/vector or Raster to load
          modsfn = File.join(rootdir, 'metadata', 'descMetadata.xml')
          fail "load-geoserver: #{druid} cannot locate MODS: #{modsfn}" unless File.size?(modsfn)

          format = GisRobotSuite.determine_file_format_from_mods modsfn
          fail "load-geoserver: #{druid} cannot determine file format from MODS" if format.nil?
          rights = determine_rights(druid).downcase
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
          LyberCore::Log.debug "GeoServer options: #{Settings.geoserver[rights][:primary]}"
          connection = Geoserver::Publish::Connection.new(
            {
              "url" => Settings.geoserver[rights][:primary][:url],
              "user" => Settings.geoserver[rights][:primary][:user],
              "password" => Settings.geoserver[rights][:primary][:password]
            }
          )

          # Obtain a handle to the workspace and clean it up.
          ws = Geoserver::Publish::Workspace.new(connection)
          workspace_name = 'druid'

          fail "load-geoserver: #{druid}: No such workspace: #{workspace_name}" unless ws.find(workspace_name: workspace_name)

          LyberCore::Log.debug "Workspace: #{workspace_name} ready"

          if layer['vector'] && layer['vector']['format'] == 'PostGIS'
            create_vector(connection, ws, layer['vector'], workspace_name)
          elsif layer['raster'] && layer['raster']['format'] == 'GeoTIFF'
            create_raster(connection, ws, layer['raster'], workspace_name)
          else
            fail "load-geoserver: #{druid} has unknown layer format: #{layer}"
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

        def create_vector(connection, ws, layer, workspace_name, dsname = 'postgis_druid')
          druid = layer['druid']
          %w(title abstract keywords).each do |i|
            fail ArgumentError, "load-geoserver: #{druid} layer is missing #{i}" unless layer.include?(i) && !layer[i].empty?
          end

          LyberCore::Log.debug "Retrieving DataStore: #{workspace_name}/#{dsname}"
          ds = Geoserver::Publish::DataStore.new(connection)
          fail "load-geoserver: #{druid}: Datastore #{dsname} not found" unless ds.find(workspace_name: workspace_name, data_store_name: dsname)

          feature_type_exists = Geoserver::Publish::FeatureType.new(connection).find(
            workspace_name: workspace_name,
            data_store_name: dsname,
            feature_type_name: druid
          )

          resource_action = case feature_type_exists
                            when nil
                              LyberCore::Log.debug "Creating FeatureType #{druid}"
                              :create
                            else
                              LyberCore::Log.debug "Found existing FeatureType #{druid}"
                              :update
                            end

          feature_type = Struct.new(:enabled, :title, :abstract, :keywords, :metadata_links, :metadata)
          ft = feature_type.new
          ft.enabled = true
          ft.title = layer['title']
          ft.abstract = layer['abstract']
          ft.keywords = { string: [layer['keywords']].flatten.compact.uniq }
          ft.metadata_links = []
          ft.metadata = ft.metadata || {}.merge!(
            'cacheAgeMax' => 86400,
            'cachingEnabled' => true
          )
          begin
            Geoserver::Publish::FeatureType.new(connection).send(
              resource_action,
              workspace_name: workspace_name,
              data_store_name: dsname,
              feature_type_name: druid,
              title: layer['title'],
              additional_payload: ft.to_h
            )
          rescue Geoserver::Publish::Error => e
            fail "load-geoserver: #{druid} cannot save FeatureType: #{e.message}"
          end
        end

        def create_raster(connection, ws, layer, workspace_name)
          druid = layer['druid']
          %w(title abstract keywords).each do |i|
            fail ArgumentError, "load-geoserver: #{druid}: Layer is missing #{i}" unless layer.include?(i) && !layer[i].empty?
          end

          # create coverage store
          LyberCore::Log.debug "Retrieving CoverageStore: #{workspace_name}/#{druid}"
          coverage_store = Geoserver::Publish::CoverageStore.new(connection)
          coverage_store_exists = coverage_store.find(
            coverage_store_name: druid,
            workspace_name: workspace_name
          )
          if coverage_store_exists.nil?
            LyberCore::Log.debug "Creating CoverageStore: #{workspace_name}/#{druid}"
            begin
              coverage_store.create(
                workspace_name: workspace_name,
                coverage_store_name: druid,
                url: "file:#{Settings.geohydra.geotiff.dir}/#{druid}.tif",
                type: 'GeoTIFF',
                additional_payload: {
                  description: layer['title']
                }
              )
            rescue Geoserver::Publish::Error => e
              fail "load-geoserver: #{druid} cannot save CoverageStore: #{e.message}"
            end
          else
            LyberCore::Log.debug "load-geoserver:: #{druid} found existing CoverageStore: #{workspace_name}/#{druid}"
          end

          # create or update coverage
          LyberCore::Log.debug "Retrieving Coverage: #{workspace_name}/#{druid}/#{druid}"
          coverage = Geoserver::Publish::Coverage.new(connection)
          coverage_exists = coverage.find(
            coverage_name: druid,
            coverage_store_name: druid,
            workspace_name: workspace_name
          )

          if coverage_exists.nil?
            LyberCore::Log.debug "Creating Coverage #{druid}"
          else
            LyberCore::Log.debug "Found existing Coverage #{druid}"
          end
          coverage_struct = Struct.new(:enabled, :title, :abstract, :keywords, :metadata_links, :metadata)
          cv = coverage_struct.new
          cv.enabled = true
          cv.title = layer['title']
          cv.abstract = layer['abstract']
          cv.keywords = [cv.keywords, layer['keywords']].flatten.compact.uniq
          cv.metadata_links = []
          cv.metadata = cv.metadata || {}.merge!(
            'cacheAgeMax' => 86400,
            'cachingEnabled' => true
          )
          begin
            coverage.create(
              workspace_name: workspace_name,
              coverage_store_name: druid,
              coverage_name: druid,
              title: layer['title'],
              additional_payload: cv.to_h
            )
          rescue Geoserver::Publish::Error => e
            fail "load-geoserver: #{druid} cannot save Coverage: #{e.message}"
          end

          # determine raster style
          begin
            raster_style = 'raster_' + GisRobotSuite.determine_raster_style("#{Settings.geohydra.geotiff.dir}/#{druid}.tif")
          rescue => e
            LyberCore::Log.info "Raster style determination failed. Using default `raster`"
            raster_style = 'raster'
          end
          LyberCore::Log.debug "load-geoserver: #{druid} determined raster style as '#{raster_style}'"
          style = Geoserver::Publish::Style.new(connection)
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
              style_exists = style.find(
                style_name: raster_style
              )
              LyberCore::Log.debug "load-geoserver: #{druid} loaded style #{raster_style}"
              if style_exists.nil?
                LyberCore::Log.debug "load-geoserver: #{druid} saving new style #{raster_style}"
                style.create(style_name: raster_style)
                style.update(style_name: raster_style, filename: nil, payload: sldtxt)
              end
            else
              raster_style = 'raster_grayband' # a simple band-oriented histogram adjusted style
              style_exists = style.find(
                style_name: raster_style
              )
              fail "load-geoserver: #{druid} has missing style #{raster_style}" if style_exists.nil?
            end
          else
            style_exists = style.find(
              style_name: raster_style
            )
            fail "load-geoserver: #{druid} has missing style #{raster_style}" if style_exists.nil?
          end

          # fetch layer to load raster style - it's created when the coverage is created via REST API
          layer = Geoserver::Publish::Layer.new(connection)
          layer_exists = layer.find(layer_name: druid)
          if layer_exists.nil?
            fail "load-geoserver: Layer #{druid} is missing for coverage #{workspace_name}/#{druid}/#{druid}"
          end

          if layer_exists.dig('layer', 'defaultStyle', 'name') != raster_style
            layer_exists['layer']['defaultStyle'] = raster_style
            LyberCore::Log.debug "load-geoserver: #{druid} updating #{druid} with default style #{raster_style}"
            begin
              layer.update(layer_name: druid, additional_payload: layer_exists)
            rescue Geoserver::Publish::Error => e
              fail "load-geoserver: #{druid} cannot save Layer: #{e.message}"
            end
          end
        end

        def determine_rights(druid)
          rights = 'Restricted'
          xml = Dor.find("druid:#{druid}").rightsMetadata.ng_xml
          if xml.search('//rightsMetadata/access[@type=\'read\']/machine/world').length > 0
            rights = 'Public'
          end

          rights
        end
      end
    end
  end
end
