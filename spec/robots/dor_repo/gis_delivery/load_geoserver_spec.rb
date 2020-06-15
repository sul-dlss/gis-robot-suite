# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisDelivery::LoadGeoserver do
  let(:robot) { described_class.new }
  let(:workflow_client) { instance_double(Dor::Workflow::Client) }

  before do
    allow(WorkflowClientFactory).to receive(:build).and_return(workflow_client)
    stub_request(:get, "http://example.com/geoserver/rest/workspaces/druid.xml")
      .to_return(status: 200, body: read_fixture('geoserver_responses/workspaces.xml'), headers: {})
    stub_request(:get, "http://example.com/geoserver/rest/workspaces/druid/datastores.xml")
      .to_return(status: 200, body: read_fixture('geoserver_responses/datastores.xml'), headers: {})
    stub_request(:get, "http://example.com/geoserver/rest/workspaces/druid/coveragestores.xml")
      .to_return(status: 200, body: '<coverageStores/>', headers: {})
    stub_request(:get, "http://example.com/geoserver/rest/workspaces/druid/wmsstores.xml")
      .to_return(status: 200, body: '<wmsStores/>', headers: {})
    stub_request(:get, "http://example.com/geoserver/rest/workspaces/druid/wmtsstores.xml")
      .to_return(status: 200, body: '<wmtsStores/>', headers: {})
  end

  describe '#perform' do
    describe 'loading a vector dataset' do
      let(:druid) { 'bb338jh0716' }
      let(:post_body) do
        "<?xml version=\"1.0\"?>\n<featureType>\n  <nativeName>bb338jh0716</nativeName>\n  <name>bb338jh0716</name>\n  <enabled>true</enabled>\n  <title>Hydrologic Sub-Area Boundaries: Russian River Watershed, California, 1999</title>\n  <abstract>This polygon dataset represents the Hydrologic Sub-Area boundaries for the Russian River basin, as defined by the Calwater 2.2a watershed boundaries. The original CALWATER22 layer (Calwater 2.2a watershed boundaries) was developed as a coverage named calw22a and is administered by the Interagency California Watershed Mapping Committee (ICWMC). \nThis shapefile can be used to map and analyze data at the Hydrologic Sub-Area scale.</abstract>\n  <keywords>\n    <string>Hydrology</string>\n    <string>Watersheds</string>\n    <string>Boundaries</string>\n    <string>Inland Waters</string>\n    <string>Sonoma County (Calif.)</string>\n    <string>Mendocino County (Calif.)</string>\n    <string>Russian River Watershed (Calif.)</string>\n  </keywords>\n  <store class=\"dataStore\">\n    <name>postgis_druid</name>\n  </store>\n  <projectionPolicy>NONE</projectionPolicy>\n</featureType>\n" # rubocop:disable Layout/LineLength
      end

      before do
        stub_request(:get, "http://example.com/geoserver/rest/workspaces/druid/datastores/postgis_druid.xml")
          .to_return(status: 200, body: read_fixture('geoserver_responses/postgis_druid.xml'), headers: {})
        stub_request(:get, "http://example.com/geoserver/rest/workspaces/druid/datastores/postgis_druid/featuretypes/bb338jh0716.xml")
          .to_return(status: 404)
      end
      it 'runs without error' do
        stubbed_post = stub_request(:post, 'http://example.com/geoserver/rest/workspaces/druid/datastores/postgis_druid/featuretypes.xml')
                       .with(headers: { 'Content-Type' => 'application/xml' }, body: post_body)
                       .to_return(status: 201)
        robot.perform(druid)
        expect(stubbed_post).to have_been_requested
      end
    end
  end
end
