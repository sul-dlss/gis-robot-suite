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
    let(:geo_metadata) { instance_double(Dor::GeoMetadataDS, :content= => true) }
    let(:item) do
      instance_double(Dor::Item, datastreams: { 'geoMetadata' => geo_metadata },
                                 tags: [],
                                 save: true)
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
      allow(Dor::TagService).to receive(:add)
    end

    it 'tags the object' do
      robot.perform(druid)
      expect(Dor::TagService).to have_received(:add).with(item, 'Dataset : GIS')
      expect(item).to have_received(:save)
    end
  end
end
