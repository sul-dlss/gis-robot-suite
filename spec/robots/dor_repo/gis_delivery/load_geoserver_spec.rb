# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisDelivery::LoadGeoserver do
  let(:robot) { described_class.new }
  let(:workflow_client) { instance_double(Dor::Workflow::Client) }

  before do
    allow(WorkflowClientFactory).to receive(:build).and_return(workflow_client)
    stub_request(:get, "http://example.com/geoserver/rest/workspaces/druid")
      .to_return(status: 200, body: read_fixture('geoserver_responses/workspaces.json'), headers: {})
  end

  describe '#determine_rights' do
    before do
      allow(Dor).to receive(:find).and_return(dor_item)
    end

    context 'when public' do
      let(:dor_item) do
        Dor::Item.new(pid: druid).tap do |item|
          item.rightsMetadata.content = read_fixture('workspace/fx/392/st/8577/fx392st8577/metadata/rightsMetadata.xml')
        end
      end

      let(:druid) { 'fx392st8577' }

      it do
        expect(robot.determine_rights(druid)).to be 'Public'
      end
    end

    context 'when restricted' do
      let(:dor_item) do
        Dor::Item.new(pid: druid).tap do |item|
          item.rightsMetadata.content = read_fixture('workspace/bb/338/jh/0716/bb338jh0716/metadata/rightsMetadata.xml')
        end
      end

      let(:druid) { 'fx392st8577' }

      it do
        expect(robot.determine_rights(druid)).to be 'Restricted'
      end
    end
  end

  describe '#perform' do
    before do
      allow(robot).to receive(:determine_rights).and_return 'Public'
    end

    describe 'loading a vector dataset' do
      let(:druid) { 'bb338jh0716' }
      let(:post_body) do
        "{\"featureType\":{\"name\":\"bb338jh0716\",\"title\":\"Hydrologic Sub-Area Boundaries: Russian River Watershed, California, 1999\",\"enabled\":true,\"abstract\":\"This polygon dataset represents the Hydrologic Sub-Area boundaries for the Russian River basin, as defined by the Calwater 2.2a watershed boundaries. The original CALWATER22 layer (Calwater 2.2a watershed boundaries) was developed as a coverage named calw22a and is administered by the Interagency California Watershed Mapping Committee (ICWMC). \\nThis shapefile can be used to map and analyze data at the Hydrologic Sub-Area scale.\",\"keywords\":{\"string\":[\"Hydrology\",\"Watersheds\",\"Boundaries\",\"Inland Waters\",\"Sonoma County (Calif.)\",\"Mendocino County (Calif.)\",\"Russian River Watershed (Calif.)\"]},\"metadata_links\":[],\"metadata\":{\"cacheAgeMax\":86400,\"cachingEnabled\":true}}}" # rubocop:disable Layout/LineLength
      end

      before do
        stub_request(:get, "http://example.com/geoserver/rest/workspaces/druid/datastores/postgis_druid")
          .to_return(status: 200, body: read_fixture('geoserver_responses/postgis_druid.json'), headers: {})
      end

      it 'runs without error' do
        stub_request(:get, "http://example.com/geoserver/rest/workspaces/druid/datastores/postgis_druid/featuretypes/bb338jh0716")
          .to_return(status: 404)
        stubbed_post = stub_request(:post, 'http://example.com/geoserver/rest/workspaces/druid/datastores/postgis_druid/featuretypes')
                       .with(headers: { 'Content-Type' => 'application/json' }, body: post_body)
                       .to_return(status: 201)
        robot.perform(druid)
        expect(stubbed_post).to have_been_requested
      end

      it 'already existing, runs without error' do
        stub_request(:get, "http://example.com/geoserver/rest/workspaces/druid/datastores/postgis_druid/featuretypes/bb338jh0716")
          .to_return(status: 200, body: {}.to_json)
        stubbed_post = stub_request(:put, 'http://example.com/geoserver/rest/workspaces/druid/datastores/postgis_druid/featuretypes/bb338jh0716')
                       .with(headers: { 'Content-Type' => 'application/json' }, body: post_body)
                       .to_return(status: 201)
        robot.perform(druid)
        expect(stubbed_post).to have_been_requested
      end
    end

    describe 'loading a raster dataset' do
      let(:druid) { 'dg548ft1892' }
      let(:store_post_body) do
        "{\"coverageStore\":{\"name\":\"dg548ft1892\",\"url\":\"file:/geotiff/dg548ft1892.tif\",\"enabled\":true,\"workspace\":{\"name\":\"druid\"},\"type\":\"GeoTIFF\",\"_default\":false,\"description\":\"1000 Meter Resolution Bathymetry Grid of Exclusive Economic Zone (EEZ): Russian River Basin, California, 1998\"}}" # rubocop:disable Layout/LineLength
      end
      let(:coverage_post_body) do
        "{\"coverage\":{\"enabled\":true,\"name\":\"dg548ft1892\",\"title\":\"1000 Meter Resolution Bathymetry Grid of Exclusive Economic Zone (EEZ): Russian River Basin, California, 1998\",\"abstract\":\"Eez1000 is a 1000 meter resolution statewide bathymetric dataset that generally covers the Exclusive Economic Zone (EEZ), an area extending 200 nautical miles from all United States possessions and trust territories. The data was adapted from isobath values ranging from 200 meters to 4800 meters below sea level; therefore nearshore depictions ARE NOT ACCURATE and \\\"flatten out\\\" between 200 meter depths and the coastline. The data is intended only for general portrayals of offshore features and depths. The Department of Fish and Game (DFG), Technical Services Branch (TSB) GIS Unit received the source data in the form of a line contour coverage (known as DFG's eezbath) from the United States Geological Survey (USGS). The contour data was converted to a TIN (triangulated irregular network) using ArcView 3D Analyst and then converted to a grid. The contour data was previously reprojected by TSB to Albers conic equal-area using standard Teale Data Center parameters. Some minor aesthetic editing was performed on peripheral areas using the ARC/INFO Grid EXPAND function. The image version was created using the ARC/INFO GRIDIMAGE function. Please see the attached metadata file \\\"eezbatcall.doc\\\" or the DFG coverage metadata \\\"eezbath.txt\\\" for further source data information.\\nThis layer can be used for watershed analysis and planning in the Russian River region of California.\",\"keywords\":{\"string\":[\"Hydrography\",\"Watersheds\",\"Inland Waters\",\"Sonoma County (Calif.)\",\"Mendocino County (Calif.)\",\"Russian River Watershed (Calif.)\"]},\"metadata_links\":[],\"metadata\":{\"cacheAgeMax\":86400,\"cachingEnabled\":true}}}" # rubocop:disable Layout/LineLength
      end
      let(:layer_put_body) do
        "{\"layer\":{\"name\":\"dg548ft1892\",\"path\":\"\",\"type\":\"RASTER\",\"defaultStyle\":\"raster\",\"resource\":{\"@class\":\"coverage\",\"name\":\"druid:dg548ft1892\",\"href\":\"http://example.com/geoserver/rest/workspaces/druid/coveragestores/dg548ft1892/coverages/dg548ft1892.json\"},\"queryable\":false,\"opaque\":false}}" # rubocop:disable Layout/LineLength
      end

      before do
        stub_request(:get, 'http://example.com/geoserver/rest/workspaces/druid/coveragestores/dg548ft1892')
          .to_return(status: 404)
        stub_request(:get, 'http://example.com/geoserver/rest/workspaces/druid/coveragestores/dg548ft1892/coverages/dg548ft1892')
          .to_return(status: 404)
        stub_request(:get, 'http://example.com/geoserver/rest/styles/raster')
          .to_return(status: 200, body: '{"style":{"name":"raster","format":"sld","languageVersion":{"version":"1.0.0"},"filename":"raster.sld"}}')
        stub_request(:get, 'http://example.com/geoserver/rest/layers/dg548ft1892')
          .to_return(status: 200, body: '{"layer":{"name":"dg548ft1892","path":"","type":"RASTER","defaultStyle":{"name":"raster_rgb8","href":"http://example.com/geoserver/rest/styles/raster_rgb8.json"},"resource":{"@class":"coverage","name":"druid:dg548ft1892","href":"http://example.com/geoserver/rest/workspaces/druid/coveragestores/dg548ft1892/coverages/dg548ft1892.json"},"queryable":false,"opaque":false}}') # rubocop:disable Layout/LineLength
      end

      it 'runs without error' do
        stubbed_store_post = stub_request(:post, 'http://example.com/geoserver/rest/workspaces/druid/coveragestores')
                             .with(headers: { 'Content-Type' => 'application/json' }, body: store_post_body)
                             .to_return(status: 201)
        stubbed_coverage_post = stub_request(:post, 'http://example.com/geoserver/rest/workspaces/druid/coveragestores/dg548ft1892/coverages')
                                .with(headers: { 'Content-Type' => 'application/json' }, body: coverage_post_body)
                                .to_return(status: 201)
        stubbed_layer_put = stub_request(:put, 'http://example.com/geoserver/rest/layers/dg548ft1892')
                            .with(headers: { 'Content-Type' => 'application/json' }, body: layer_put_body)
                            .to_return(status: 201)
        robot.perform(druid)
        expect(stubbed_store_post).to have_been_requested
        expect(stubbed_coverage_post).to have_been_requested
        expect(stubbed_layer_put).to have_been_requested
      end
    end
  end
end
