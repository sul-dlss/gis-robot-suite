# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisDelivery::ResetGeowebcache do
  let(:robot) { described_class.new }
  let(:workflow_client) { instance_double(Dor::Workflow::Client) }
  let(:druid) { 'druid:fx392st8577' }

  before do
    allow(LyberCore::WorkflowClientFactory).to receive(:build).and_return(workflow_client)
    allow(GisRobotSuite).to receive(:determine_rights).and_return 'Public'
  end

  describe '#perform' do
    it 'raises an error if layer does not exist' do
      stub_request(:post, 'http://example.com/geoserver/gwc/rest/masstruncate')
        .with(body: '<truncateLayer><layerName>druid:fx392st8577</layerName></truncateLayer>')
        .to_return(status: 200)
      stub_request(:post, 'http://example-2.com/geoserver/gwc/rest/masstruncate')
        .with(body: '<truncateLayer><layerName>druid:fx392st8577</layerName></truncateLayer>')
        .to_return(status: 200)
      expect(test_perform(robot, druid)).to eq [true, true]
    end
  end
end
