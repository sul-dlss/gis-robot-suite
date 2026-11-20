# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::ExtractFgdcMetadata do
  subject(:perform) { test_perform(robot, druid) }

  let(:robot) { described_class.new }

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

  # The box extract-iso19139-metadata would have written into the ISO 19139 staged before this step
  let(:iso19139) do
    <<~XML
      <MD_Metadata xmlns="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco">
        <identificationInfo><MD_DataIdentification><extent><EX_Extent><geographicElement><EX_GeographicBoundingBox>
          <westBoundLongitude><gco:Decimal>169.5</gco:Decimal></westBoundLongitude>
          <eastBoundLongitude><gco:Decimal>-143.1</gco:Decimal></eastBoundLongitude>
          <southBoundLatitude><gco:Decimal>-17.9</gco:Decimal></southBoundLatitude>
          <northBoundLatitude><gco:Decimal>4.7</gco:Decimal></northBoundLatitude>
        </EX_GeographicBoundingBox></geographicElement></EX_Extent></extent></MD_DataIdentification></identificationInfo>
      </MD_Metadata>
    XML
  end

  # Get rid of any generated XML files
  def cleanup
    Dir.glob("#{staging_dir}/*-{fgdc,iso19139}.xml").each { |f| File.delete(f) }
  end

  def bounding_coordinates(layer_name)
    fgdc = Nokogiri::XML(File.read(File.join(staging_dir, "#{layer_name}-fgdc.xml")))
    fgdc.at_xpath('/metadata/idinfo/spdom/bounding').element_children.to_h { |element| [element.name, element.text] }
  end

  before do
    cleanup
    File.write(File.join(staging_dir, 'staged-iso19139.xml'), iso19139) if File.directory?(staging_dir)
    allow(Dor::Services::Client).to receive(:object).with(druid).and_return(object_client)
    allow(workflow_client).to receive(:process).with('extract-fgdc-metadata').and_return(process_client)
    perform
  end

  after { cleanup }

  context 'with ESRI metadata for a shapefile' do
    let(:druid) { 'druid:cv676dy5796' }
    let(:esri_filename) { 'WATER_BODY.shp.xml' }

    it 'generates an FGDC XML document and adds it to the structural metadata' do
      expect(File).to exist(File.join(staging_dir, 'WATER_BODY-fgdc.xml'))
      expect(object_client).to have_received(:update) do |args|
        file = args[:params].structural.contains.first.structural.contains.last
        expect(file.filename).to eq 'WATER_BODY-fgdc.xml'
        expect(file.use).to eq 'derivative'
        expect(file.hasMimeType).to eq 'application/xml'
      end
    end

    it 'states the bounding box from the ISO 19139, in place of the one ArcGIS recorded' do
      expect(bounding_coordinates('WATER_BODY')).to include('westbc' => '169.5', 'eastbc' => '-143.1', 'northbc' => '4.7', 'southbc' => '-17.9')
    end
  end

  context 'with ESRI metadata for a geoTIFF' do
    let(:druid) { 'druid:qt609tt2964' }
    let(:esri_filename) { '26257_e.tif.xml' }

    it 'generates an FGDC XML document and adds it to the structural metadata' do
      expect(File).to exist(File.join(staging_dir, '26257_e-fgdc.xml'))
      expect(object_client).to have_received(:update) do |args|
        file = args[:params].structural.contains.first.structural.contains.last
        expect(file.filename).to eq '26257_e-fgdc.xml'
        expect(file.use).to eq 'derivative'
        expect(file.hasMimeType).to eq 'application/xml'
      end
    end
  end

  context 'with ESRI metadata for a geoJSON' do
    let(:druid) { 'druid:vx813cc5549' }
    let(:esri_filename) { 'CLOWNS_OF_AMERICA.geojson.xml' }

    it 'generates an FGDC XML document and adds it to the structural metadata' do
      expect(File).to exist(File.join(staging_dir, 'CLOWNS_OF_AMERICA-fgdc.xml'))
      expect(object_client).to have_received(:update) do |args|
        file = args[:params].structural.contains.first.structural.contains.last
        expect(file.filename).to eq 'CLOWNS_OF_AMERICA-fgdc.xml'
        expect(file.use).to eq 'derivative'
        expect(file.hasMimeType).to eq 'application/xml'
      end
    end
  end

  context 'without ESRI metadata' do
    let(:druid) { 'druid:bb045mm1234' }
    let(:esri_filename) { 'somefile.txt' }

    it 'skips the step without updating the object' do
      expect(perform).to be_a(LyberCore::ReturnState)
      expect(perform.status).to eq 'skipped'
      expect(perform.note).to eq 'bb045mm1234 has no ESRI metadata file in staging'
      expect(object_client).not_to have_received(:update)
    end
  end
end
