# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::ExtractFgdcMetadata do
  let(:process_response) { instance_double(Dor::Services::Response::Process, status: 'queued') }
  let(:workflow_response) { instance_double(Dor::Services::Response::Workflow, process_for_recent_version: process_response) }
  let(:workflow_client) { instance_double(Dor::Services::Client::ObjectWorkflow, create: true, find: workflow_response) }
  let(:process_client) { instance_double(Dor::Services::Client::Process, update: nil, update_error: nil) }
  let(:object_client) { instance_double(Dor::Services::Client::Object, workflow: workflow_client) }
  let(:staging_dir) { File.join(DruidTools::Druid.new(druid, File.join(fixture_dir, 'stage')).path, 'content') }

  # Get rid of any generated XML files
  def cleanup
    Dir.glob("#{staging_dir}/*-fgdc.xml").each { |f| File.delete(f) }
  end

  before do
    cleanup
    allow(Dor::Services::Client).to receive(:object).with("druid:#{druid}").and_return(object_client)
    allow(workflow_client).to receive(:process).with('extract-fgdc-metadata').and_return(process_client)
    described_class.new.perform("druid:#{druid}")
  end

  after { cleanup }

  context 'with ESRI metadata for a shapefile' do
    let(:druid) { 'cv676dy5796' }
    let(:esri_filename) { 'WATER_BODY.shp.xml' }

    it 'generates an FGDC XML document' do
      expect(File).to exist(File.join(staging_dir, 'WATER_BODY-fgdc.xml'))
    end
  end

  context 'with ESRI metadata for a geoTIFF' do
    let(:druid) { 'qt609tt2964' }
    let(:esri_filename) { '26257_e.tif.xml' }

    it 'generates an FGDC XML document' do
      expect(File).to exist(File.join(staging_dir, '26257_e-fgdc.xml'))
    end
  end

  context 'with ESRI metadata for a geoJSON' do
    let(:druid) { 'vx813cc5549' }
    let(:esri_filename) { 'CLOWNS_OF_AMERICA.geojson.xml' }

    it 'generates an FGDC XML document' do
      expect(File).to exist(File.join(staging_dir, 'CLOWNS_OF_AMERICA-fgdc.xml'))
    end
  end
end
