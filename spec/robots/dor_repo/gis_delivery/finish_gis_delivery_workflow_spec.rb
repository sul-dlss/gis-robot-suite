# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisDelivery::FinishGisDeliveryWorkflow do
  let(:robot) { described_class.new }
  let(:workflow_client) { instance_double(Dor::Workflow::Client) }
  let(:druid) { 'fx392st8577' }

  before do
    allow(LyberCore::WorkflowClientFactory).to receive(:build).and_return(workflow_client)
  end

  describe '#perform_work' do
    it 'raises an error if layer does not exist' do
      stub_request(:get, 'http://example.com/geoserver/rest/layers/fx392st8577')
        .to_return(status: 404)
      stub_request(:get, 'http://example.com/restricted/geoserver/rest/layers/fx392st8577')
        .to_return(status: 404)
      expect { test_perform(robot, druid) }.to raise_error(RuntimeError, /is missing GeoServer layer/)
    end

    it 'completes successfully when it exists' do
      stub_request(:get, 'http://example.com/geoserver/rest/layers/fx392st8577')
        .to_return(status: 404)
      stub_request(:get, 'http://example.com/restricted/geoserver/rest/layers/fx392st8577')
        .to_return(status: 200)
      expect { test_perform(robot, druid) }.not_to raise_error(RuntimeError, /is missing GeoServer layer/)
    end
  end
end
