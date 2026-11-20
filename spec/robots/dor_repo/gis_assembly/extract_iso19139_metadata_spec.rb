# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::ExtractIso19139Metadata do
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

  # ISO 19139 leaves gmd as the default namespace, so queries have to map the prefix themselves.
  let(:namespaces) do
    {
      'gmd' => 'http://www.isotc211.org/2005/gmd',
      'gco' => 'http://www.isotc211.org/2005/gco',
      'gml' => 'http://www.opengis.net/gml'
    }
  end

  # Most of these fixtures stage the ArcGIS metadata without the data it describes, so the box is
  # stubbed unless a context has data to measure.
  let(:bounding_box) { GisRobotSuite::BoundingBox.new(west: 169.5, east: -143.1, north: 4.7, south: -17.9) }
  let(:measure_data) { false }

  # Get rid of any generated XML files
  def cleanup
    Dir.glob("#{staging_dir}/*-iso*.xml").each { |f| File.delete(f) }
  end

  def iso19139(layer_name)
    Nokogiri::XML(File.read(File.join(staging_dir, "#{layer_name}-iso19139.xml")))
  end

  def band_units(layer_name)
    iso19139 = Nokogiri::XML(File.read(File.join(staging_dir, "#{layer_name}-iso19139.xml")))
    iso19139.at_xpath('//gmd:MD_Band/gmd:units', namespaces)
  end

  before do
    cleanup
    allow(Dor::Services::Client).to receive(:object).with(druid).and_return(object_client)
    allow(workflow_client).to receive(:process).with('extract-iso19139-metadata').and_return(process_client)
    allow(GisRobotSuite::BoundingBox).to receive(:from_data).and_return(bounding_box) unless measure_data
    perform
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

    it 'states the bounding box computed from the data, in place of the one ArcGIS recorded' do
      expect(GisRobotSuite::Iso19139BoundingBox.read(iso19139('WATER_BODY'))).to eq bounding_box
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

    it 'records the band units as missing rather than naming a code system' do
      expect(band_units('26257_e').at_xpath('@gco:nilReason', namespaces).value).to eq 'missing'
      expect(File.read(File.join(staging_dir, '26257_e-iso19139.xml'))).not_to include 'Unified Code of Units of Measure'
    end
  end

  context 'with ESRI metadata for a geoTIFF that declares a vertical coordinate system' do
    let(:druid) { 'druid:sf815vr1246' }
    let(:esri_filename) { 'MONT_DEM.tif.xml' }

    it 'generates an ISO 19139 XML document' do
      expect(File).to exist(File.join(staging_dir, 'MONT_DEM-iso19139.xml'))
    end

    it 'records the band units from the vertical coordinate system' do
      units = band_units('MONT_DEM')

      expect(units.at_xpath('gml:UnitDefinition/gml:identifier', namespaces).text).to eq 'm'
      expect(units.at_xpath('gml:UnitDefinition/gml:name', namespaces).text).to eq 'Meter'
      expect(units.at_xpath('gml:UnitDefinition/gml:quantityType', namespaces).text).to eq 'length'
    end
  end

  context 'with ESRI metadata for geoJSON' do
    let(:druid) { 'druid:vx813cc5549' }
    let(:esri_filename) { 'CLOWNS_OF_AMERICA.geojson.xml' }
    let(:measure_data) { true }

    it 'measures the bounding box from the GeoJSON staged with it' do
      box = GisRobotSuite::Iso19139BoundingBox.read(iso19139('CLOWNS_OF_AMERICA'))

      expect(box).to have_attributes(west: be_within(0.0001).of(-158.017379), east: be_within(0.0001).of(-65.594769),
                                     north: be_within(0.0001).of(64.854370), south: be_within(0.0001).of(18.001995))
    end

    it 'generates an ISO 19139 XML document' do
      expect(File).to exist(File.join(staging_dir, 'CLOWNS_OF_AMERICA-iso19139.xml'))
      expect(object_client).to have_received(:update) do |args|
        file = args[:params].structural.contains.first.structural.contains.last
        expect(file.filename).to eq 'CLOWNS_OF_AMERICA-iso19139.xml'
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
