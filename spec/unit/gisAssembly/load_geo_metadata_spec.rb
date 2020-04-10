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
    let(:geo_metadata) { instance_double(Dor::GeoMetadataDS, :content= => true) }
    let(:item) do
      instance_double(Dor::Item,
                      datastreams: { 'geoMetadata' => geo_metadata },
                      save: true,
                      pid: 'druid:bc123df4567')
    end
    let(:xml) do
      <<~XML
        <xml />
      XML
    end

    before do
      allow(Dor::Config).to receive(:geohydra).and_return(stub_config)
      allow(File).to receive(:size?).and_return(100)
      allow(Dor::Item).to receive(:find).and_return(item)
      allow(File).to receive(:read).and_return(xml)
      allow(robot).to receive(:tags_client).with(item.pid).and_return(fake_tags_client)
    end

    it 'tags the object' do
      robot.perform(druid)
      expect(fake_tags_client).to have_received(:create).once.with(tags: ['Dataset : GIS'])
      expect(item).to have_received(:save)
    end
  end
end
