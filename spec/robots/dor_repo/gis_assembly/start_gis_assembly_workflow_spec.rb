# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::StartGisAssemblyWorkflow do
  subject(:robot) { described_class.new }

  let(:druid) { 'druid:zz000zz0001' }
  let(:object_client) { instance_double(Dor::Services::Client::Object, version: version_client) }
  let(:version_client) do
    instance_double(Dor::Services::Client::ObjectVersion,
                    status: instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: version_open))
  end
  let(:version_open) { true }

  before do
    allow(Dor::Services::Client).to receive(:object).with(druid).and_return(object_client)
  end

  describe '#perform' do
    subject(:perform) { test_perform(robot, druid) }

    it 'does not raise an error' do
      expect { perform }.not_to raise_error
    end

    context 'when object is not open' do
      let(:version_open) { false }

      it 'raises an error' do
        expect { perform }.to raise_error 'GIS assembly has been started with an object that is not open'
      end
    end
  end
end
