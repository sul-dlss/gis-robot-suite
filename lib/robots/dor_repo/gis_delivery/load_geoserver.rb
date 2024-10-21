# frozen_string_literal: true

require 'druid-tools'

module Robots
  module DorRepo
    module GisDelivery
      class LoadGeoserver < Base # rubocop:disable Metrics/ClassLength
        def initialize
          super('gisDeliveryWF', 'load-geoserver')
        end

        def perform_work
          logger.debug "load-geoserver working on #{bare_druid}"

          raise "load-geoserver: #{bare_druid} cannot determine media type" unless GisRobotSuite.media_type(cocina_object)

          rights = GisRobotSuite.determine_rights(cocina_object)

          # Connect to GeoServer
          logger.debug "GeoServer options: #{Settings.geoserver[rights][:primary]}"
          connection = Geoserver::Publish::Connection.new(
            {
              'url' => Settings.geoserver[rights][:primary][:url],
              'user' => Settings.geoserver[rights][:primary][:user],
              'password' => Settings.geoserver[rights][:primary][:password]
            }
          )

          # Obtain a handle to the workspace
          workspace = Geoserver::Publish::Workspace.new(connection)
          workspace_name = 'druid'

          raise "load-geoserver: #{bare_druid}: No such workspace: #{workspace_name}" unless workspace.find(workspace_name:)

          logger.debug "Workspace: #{workspace_name} ready"

          if vector?
            create_vector(connection, workspace_name)
          elsif raster?
            create_raster(connection, workspace_name)
          else
            raise "load-geoserver: #{bare_druid} has unknown layer format: #{layertype}"
          end
        end

        def raster?
          @raster ||= GisRobotSuite.raster?(cocina_object)
        end

        def vector?
          @vector ||= GisRobotSuite.vector?(cocina_object)
        end

        def layertype
          @layertype ||= GisRobotSuite.layertype(cocina_object)
        end

        def title
          @title ||= Cocina::Models::Builders::TitleBuilder.full_title(cocina_object.description.title).first
        end

        def abstract
          @abstract ||= cocina_object.description.note.select { |note| note.type == 'abstract' || note.displayLabel&.downcase == 'abstract' }.map(&:value).join("\n")
        end

        def keywords
          @keywords ||= (
            cocina_object.description.subject.select { |subject| subject.type == 'topic' } +
            cocina_object.description.subject.select { |subject| subject.type == 'place' })
                        .map(&:value).compact.uniq
        end

        def create_vector(connection, workspace_name, datastore_name = 'postgis_druid')
          %w[title abstract keywords].each do |field|
            raise ArgumentError, "load-geoserver: #{bare_druid}: Layer is missing #{field}" if send(field).empty?
          end

          logger.debug "Retrieving DataStore: #{workspace_name}/#{datastore_name}"
          datastore = Geoserver::Publish::DataStore.new(connection)
          raise "load-geoserver: #{bare_druid}: Datastore #{datastore_name} not found" unless datastore.find(workspace_name:, data_store_name: datastore_name)

          feature_type_exists = Geoserver::Publish::FeatureType.new(connection).find(
            workspace_name:,
            data_store_name: datastore_name,
            feature_type_name: bare_druid
          )

          resource_action = case feature_type_exists
                            when nil
                              logger.debug "Creating FeatureType #{bare_druid}"
                              :create
                            else
                              logger.debug "Found existing FeatureType #{bare_druid}"
                              :update
                            end

          feature_type = Struct.new(:enabled, :title, :abstract, :keywords, :metadata_links, :metadata)
          ft = feature_type.new
          ft.enabled = true
          ft.title = title
          ft.abstract = abstract
          ft.keywords = { string: keywords }
          ft.metadata_links = []
          ft.metadata = ft.metadata || {}.merge!(
            'cacheAgeMax' => 86400,
            'cachingEnabled' => true
          )
          begin
            Geoserver::Publish::FeatureType.new(connection).send(
              resource_action,
              workspace_name:,
              data_store_name: datastore_name,
              feature_type_name: bare_druid,
              title:,
              additional_payload: ft.to_h
            )
          rescue Geoserver::Publish::Error => e
            raise "load-geoserver: #{bare_druid} cannot save FeatureType: #{e.message}"
          end
        end

        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        def create_raster(connection, workspace_name)
          %w[title abstract keywords].each do |field|
            raise ArgumentError, "load-geoserver: #{bare_druid}: Layer is missing #{field}" if send(field).empty?
          end

          # create coverage store
          logger.debug "Retrieving CoverageStore: #{workspace_name}/#{bare_druid}"
          coverage_store = Geoserver::Publish::CoverageStore.new(connection)
          coverage_store_exists = coverage_store.find(
            coverage_store_name: bare_druid,
            workspace_name:
          )
          if coverage_store_exists.nil?
            logger.debug "Creating CoverageStore: #{workspace_name}/#{bare_druid}"
            begin
              coverage_store.create(
                workspace_name:,
                coverage_store_name: bare_druid,
                url: "file:#{Settings.geohydra.geotiff.dir}/#{bare_druid}.tif",
                type: layertype,
                additional_payload: {
                  description: title
                }
              )
            rescue Geoserver::Publish::Error => e
              raise "load-geoserver: #{bare_druid} cannot save CoverageStore: #{e.message}"
            end
          else
            logger.debug "load-geoserver:: #{bare_druid} found existing CoverageStore: #{workspace_name}/#{bare_druid}"
          end

          # create or update coverage
          logger.debug "Retrieving Coverage: #{workspace_name}/#{bare_druid}/#{bare_druid}"
          coverage = Geoserver::Publish::Coverage.new(connection)
          coverage_exists = coverage.find(
            coverage_name: bare_druid,
            coverage_store_name: bare_druid,
            workspace_name:
          )

          begin
            if coverage_exists.nil?
              logger.debug "Creating Coverage #{bare_druid}"
              coverage.create(
                workspace_name:,
                coverage_store_name: bare_druid,
                coverage_name: bare_druid,
                title:,
                additional_payload: coverage_metadata
              )
            else
              logger.debug "Found existing Coverage #{bare_druid}. Updating Coverage."
              coverage.update(
                workspace_name:,
                coverage_store_name: bare_druid,
                coverage_name: bare_druid,
                title:,
                additional_payload: coverage_metadata
              )
            end
          rescue Geoserver::Publish::Error => e
            raise "load-geoserver: #{bare_druid} cannot save Coverage: #{e.message}"
          end

          # determine raster style
          begin
            raster_style = "raster_#{GisRobotSuite.determine_raster_style("#{Settings.geohydra.geotiff.dir}/#{bare_druid}.tif", logger:)}"
          rescue StandardError => e
            logger.info "Raster style determination failed: #{e.inspect}. Using default `raster`"
            raster_style = 'raster'
          end
          logger.debug "load-geoserver: #{bare_druid} determined raster style as '#{raster_style}'"
          style = Geoserver::Publish::Style.new(connection)
          # need to create a style if it's a min/max style
          if raster_style =~ /^raster_grayscale_(.+)_(.+)$/
            min = Regexp.last_match(1).to_f.floor
            max = Regexp.last_match(2).to_f.ceil
            if max < 2**13 # custom SLD only works with relatively narrow bands
              # generate SLD definition
              raster_style = "raster_#{bare_druid}"
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
                  <ColorMapEntry color='#000000' quantity='#{min}' opacity='1'/>
                  <ColorMapEntry color='#FFFFFF' quantity='#{max}' opacity='1'/>
                </ColorMap>
              </RasterSymbolizer>
            </Rule>
          </FeatureTypeStyle>
      </UserStyle>
    </UserLayer>
  </StyledLayerDescriptor>"

              # create a style with the SLD definition
              style_exists = style.find(
                style_name: raster_style
              )
              logger.debug "load-geoserver: #{bare_druid} loaded style #{raster_style}"
              if style_exists.nil?
                logger.debug "load-geoserver: #{bare_druid} saving new style #{raster_style}"
                filename = "#{raster_style}.sld"
                style.create(style_name: raster_style, filename:)
                style.update(style_name: raster_style, filename:, payload: sldtxt)
              end
            else
              raster_style = 'raster_grayband' # a simple band-oriented histogram adjusted style
              style_exists = style.find(
                style_name: raster_style
              )
              raise "load-geoserver: #{bare_druid} has missing style #{raster_style}" if style_exists.nil?
            end
          else
            style_exists = style.find(
              style_name: raster_style
            )
            raise "load-geoserver: #{bare_druid} has missing style #{raster_style}" if style_exists.nil?
          end

          # fetch layer to load raster style - it's created when the coverage is created via REST API
          layer = Geoserver::Publish::Layer.new(connection)
          layer_exists = layer.find(layer_name: bare_druid)
          raise "load-geoserver: Layer #{bare_druid} is missing for coverage #{workspace_name}/#{bare_druid}/#{bare_druid}" if layer_exists.nil?

          return if layer_exists.dig('layer', 'defaultStyle', 'name') == raster_style

          layer_exists['layer']['defaultStyle'] = raster_style
          layer_exists['layer']['queryable'] = true

          logger.debug "load-geoserver: #{bare_druid} updating #{bare_druid} with default style #{raster_style}"
          begin
            layer.update(layer_name: bare_druid, additional_payload: layer_exists)
          rescue Geoserver::Publish::Error => e
            raise "load-geoserver: #{bare_druid} cannot save Layer: #{e.message}"
          end
        end
        # rubocop:enable Metrics/MethodLength

        def coverage_metadata
          { enabled: true,
            title:,
            abstract:,
            keywords: { string: keywords },
            metadata_links: [],
            metadata: {
              cacheAgeMax: 86400,
              cachingEnabled: true
            } }
        end
        # rubocop:enable Metrics/AbcSize
      end
    end
  end
end
