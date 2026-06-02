# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::ExtractIso19139Metadata do
  let(:process_response) { instance_double(Dor::Services::Response::Process, status: 'queued') }
  let(:workflow_response) { instance_double(Dor::Services::Response::Workflow, process_for_recent_version: process_response) }
  let(:workflow_client) { instance_double(Dor::Services::Client::ObjectWorkflow, create: true, find: workflow_response) }
  let(:process_client) { instance_double(Dor::Services::Client::Process, update: nil, update_error: nil) }
  let(:object_client) { instance_double(Dor::Services::Client::Object, workflow: workflow_client, find: cocina_model, update: true) }
  let(:staging_dir) { File.join(DruidTools::Druid.new(namespaceless_druid, File.join(fixture_dir, 'stage')).path, 'content') }
  let(:namespaceless_druid) { druid.delete_prefix('druid:') }
  let(:cocina_model) do
    build(:dro, id: druid).new(
      structural: {
        contains: [
          {
            type: 'https://cocina.sul.stanford.edu/models/resources/object',
            externalIdentifier: 'https://cocina.sul.stanford.edu/fileset/1234',
            label: 'Fileset 1',
            version: 1,
            structural: {
              contains: [
                {
                  type: 'https://cocina.sul.stanford.edu/models/file',
                  externalIdentifier: 'https://cocina.sul.stanford.edu/file/1',
                  label: esri_filename,
                  filename: esri_filename,
                  version: 1,
                  hasMimeType: 'application/xml',
                  use: 'master',
                  administrative: { publish: true, sdrPreserve: true, shelve: true },
                  access: { view: 'world', download: 'world' },
                  hasMessageDigests: []
                }
              ]
            }
          }
        ],
        hasMemberOrders: [],
        isMemberOf: ['druid:rz415nf2825']
      },
      access: cocina_object_access
    )
  end
  let(:esri_filename) { '' }
  let(:cocina_object_access) do
    {
      view: 'world',
      download: 'world',
      controlledDigitalLending: false
    }
  end

  # Get rid of any generated XML files
  def cleanup
    Dir.glob("#{staging_dir}/*-iso*.xml").each { |f| File.delete(f) }
  end

  before do
    cleanup
    allow(Dor::Services::Client).to receive(:object).with(druid).and_return(object_client)
    allow(workflow_client).to receive(:process).with('extract-iso19139-metadata').and_return(process_client)
    described_class.new.perform(druid)
  end

  after { cleanup }

  context 'with ESRI metadata for a shapefile' do
    let(:druid) { 'druid:cv676dy5796' }
    let(:esri_filename) { 'WATER_BODY.shp.xml' }

    it 'generates an ISO 19139 XML document' do
      expect(File).to exist(File.join(staging_dir, 'WATER_BODY-iso19139.xml'))
      expect(object_client).to have_received(:update) do |args|
        file = args[:params].structural.contains.first.structural.contains.last
        expect(file.filename).to eq 'WATER_BODY-iso19139.xml'
      end
    end
  end

  context 'with ESRI metadata for a geoTIFF' do
    let(:druid) { 'druid:qt609tt2964' }
    let(:esri_filename) { '26257_e.tif.xml' }

    it 'generates an ISO 19139 XML document' do
      expect(File).to exist(File.join(staging_dir, '26257_e-iso19139.xml'))
      expect(object_client).to have_received(:update) do |args|
        file = args[:params].structural.contains.first.structural.contains.last
        expect(file.filename).to eq '26257_e-iso19139.xml'
      end
    end
  end

  context 'with ESRI metadata for geoJSON' do
    let(:druid) { 'druid:vx813cc5549' }
    let(:esri_filename) { 'CLOWNS_OF_AMERICA.geojson.xml' }

    it 'generates an ISO 19139 XML document' do
      expect(File).to exist(File.join(staging_dir, 'CLOWNS_OF_AMERICA-iso19139.xml'))
      expect(object_client).to have_received(:update) do |args|
        file = args[:params].structural.contains.first.structural.contains.last
        expect(file.filename).to eq 'CLOWNS_OF_AMERICA-iso19139.xml'
      end
    end
  end
end
