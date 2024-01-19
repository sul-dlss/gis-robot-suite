# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::GenerateGeoMetadata do
  let(:workflow_client) { instance_double(Dor::Workflow::Client) }
  let(:robot) { described_class.new }
  let(:druid) { 'druid:bb000dd1111' }
  let(:staging_dir) { File.join(fixture_dir, 'stage', 'bb000dd1111', 'temp') }
  let(:iso19139_file) { File.join(staging_dir, 'WATER_BODY-iso19139.xml') }
  let(:iso19139_ng_xml) { Nokogiri::XML(File.read(iso19139_file)) }
  let(:iso19110_file) { File.join(staging_dir, 'WATER_BODY-iso19110.xml') }
  let(:iso19110_ng_xml) { Nokogiri::XML(File.read(iso19110_file)) }
  let(:purl) { 'https://purl.stanford.edu/bb000dd1111' }

  before do
    allow(LyberCore::WorkflowClientFactory).to receive(:build).and_return(workflow_client)
  end

  describe '#perform' do
    let(:object_client) do
      instance_double(Dor::Services::Client::Object, find: cocina, update: true, administrative_tags: fake_tags_client)
    end
    let(:fake_tags_client) do
      instance_double(Dor::Services::Client::AdministrativeTags, list: [], create: nil)
    end
    let(:cocina) do
      Cocina::Models::DRO.new(externalIdentifier: 'druid:bb000dd1111',
                              type: Cocina::Models::ObjectType.geo,
                              label: 'my repository object',
                              version: 1,
                              access: {},
                              description: {
                                title: [{ value: 'my repository object' }],
                                purl: 'https://purl.stanford.edu/bb000dd1111'
                              },
                              structural: {},
                              identification: { sourceId: 'sul:1234' },
                              administrative: {
                                hasAdminPolicy: 'druid:hv992ry2431'
                              })
    end

    before do
      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    end

    it 'updates the object' do
      test_perform(robot, druid)
      expect(object_client).to have_received(:update).with(params: Cocina::Models::DRO)
      expect(fake_tags_client).to have_received(:create).once.with(tags: ['Dataset : GIS'])
    end
  end

  describe '#geo_metadata_rdf_xml' do
    it 'runs without error' do
      expect do
        robot.send(:geo_metadata_rdf_xml, iso19139_ng_xml, iso19110_ng_xml, purl)
      end.not_to raise_error
    end
  end
end
