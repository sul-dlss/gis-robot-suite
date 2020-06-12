require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::LoadGeoMetadata do
  let(:workflow_client) { instance_double(Dor::Workflow::Client) }
  let(:robot) { described_class.new }

  before do
    allow(Dor::Config.workflow).to receive(:client).and_return(workflow_client)
  end

  describe '#perform' do
    let(:druid) { 'druid:12345' }
    let(:stub_config) { double('Geohydra config', stage: '/stage') }
    let(:fake_tags_client) do
      instance_double(Dor::Services::Client::AdministrativeTags, list: [], create: nil)
    end
    let(:object_client) do
      instance_double(Dor::Services::Client::Object, metadata: metadata_client)
    end
    let(:metadata_client) do
      instance_double(Dor::Services::Client::Metadata, legacy_update: true)
    end
    let(:xml) do
      <<~XML
        <xml />
      XML
    end

    before do
      allow(Dor::Config).to receive(:geohydra).and_return(stub_config)
      allow(File).to receive(:size?).and_return(100)
      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
      allow(File).to receive(:read).and_return(xml)
      allow(File).to receive(:mtime).and_return(Time.now)
      allow(robot).to receive(:tags_client).with(druid).and_return(fake_tags_client)
    end

    it 'tags the object' do
      robot.perform(druid)
      expect(fake_tags_client).to have_received(:create).once.with(tags: ['Dataset : GIS'])
      expect(metadata_client).to have_received(:legacy_update).with(
        geo: {
          updated: Time,
          content: "<xml />\n"
        }
      )
    end
  end
end
