# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisDiscovery::GenerateGeoblacklight do
  let(:robot) { described_class.new }
  let(:workflow_client) { instance_double(Dor::Workflow::Client) }

  before do
    allow(WorkflowClientFactory).to receive(:build).and_return(workflow_client)
  end

  describe '#perform' do
    describe 'loading transforming mods to geoblacklight' do
      let(:druid) { 'bb338jh0716' }

      it 'runs without error' do
        expect(robot).to receive(:retrieve_mods).and_return read_fixture('workspace/bb/338/jh/0716/bb338jh0716/metadata/descMetadata.xml')
        expect(robot).to receive(:determine_rights).and_return 'Public'
        expect(robot).to receive(:convert_mods2geoblacklight).and_return ''
        expect(robot).to receive(:enhance_geoblacklight).and_return ''
        robot.perform(druid)
      end
    end
  end
end
