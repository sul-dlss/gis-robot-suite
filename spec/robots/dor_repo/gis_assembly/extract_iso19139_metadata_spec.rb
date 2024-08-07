# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::ExtractIso19139Metadata do
  let(:workflow_client) { instance_double(Dor::Workflow::Client) }
  let(:staging_dir) { File.join(DruidTools::Druid.new(druid, File.join(fixture_dir, 'stage')).path, 'content') }

  # Get rid of any generated XML files
  def cleanup
    Dir.glob("#{staging_dir}/*-iso*.xml").each { |f| File.delete(f) }
  end

  before do
    cleanup
    allow(LyberCore::WorkflowClientFactory).to receive(:build).and_return(workflow_client)
    allow(workflow_client).to receive(:workflow_status).and_return('queued')
    allow(workflow_client).to receive(:update_status)
    allow(workflow_client).to receive(:update_error_status)
    described_class.new.perform("druid:#{druid}")
  end

  after { cleanup }

  context 'with ESRI metadata for a shapefile' do
    let(:druid) { 'cv676dy5796' }
    let(:esri_filename) { 'WATER_BODY.shp.xml' }

    it 'generates an ISO 19139 XML document' do
      expect(File).to exist(File.join(staging_dir, 'WATER_BODY-iso19139.xml'))
    end
  end

  context 'with ESRI metadata for a geoTIFF' do
    let(:druid) { 'qt609tt2964' }
    let(:esri_filename) { '26257_e.tif.xml' }

    it 'generates an ISO 19139 XML document' do
      expect(File).to exist(File.join(staging_dir, '26257_e-iso19139.xml'))
    end
  end

  context 'with ESRI metadata for geoJSON' do
    let(:druid) { 'vx813cc5549' }
    let(:esri_filename) { 'CLOWNS_OF_AMERICA.geojson.xml' }

    it 'generates an ISO 19139 XML document' do
      expect(File).to exist(File.join(staging_dir, 'CLOWNS_OF_AMERICA-iso19139.xml'))
    end
  end
end
