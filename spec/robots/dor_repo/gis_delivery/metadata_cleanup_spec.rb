# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisDelivery::MetadataCleanup do
  let(:process_response) { instance_double(Dor::Services::Response::Process, status: 'queued') }
  let(:workflow_response) { instance_double(Dor::Services::Response::Workflow, process_for_recent_version: process_response) }
  let(:workflow_client) { instance_double(Dor::Services::Client::ObjectWorkflow, create: true, find: workflow_response) }
  let(:process_client) { instance_double(Dor::Services::Client::Process, update: nil) }
  let(:object_client) { instance_double(Dor::Services::Client::Object, workflow: workflow_client) }
  let(:source_druid) { 'cv676dy5796' }
  let(:source_dir) { File.join(DruidTools::Druid.new(source_druid, File.join(fixture_dir, 'stage')).path, 'content') }
  let(:staging_dir) { DruidTools::Druid.new(druid, File.join(fixture_dir, 'stage')).path }

  before do
    FileUtils.mkdir_p(staging_dir)
    FileUtils.cp_r(source_dir, staging_dir)
    allow(Dor::Services::Client).to receive(:object).with("druid:#{druid}").and_return(object_client)
    allow(workflow_client).to receive(:process).with('metadata-cleanup').and_return(process_client)
  end

  context 'with ESRI metadata for a shapefile' do
    let(:druid) { 'ab123cd4567' }
    let(:esri_filename) { 'WATER_BODY.shp.xml' }

    it 'generates an ISO 19139 XML document' do
      expect(File.directory?(File.join(staging_dir, 'content'))).to be true
      expect(File).to exist(File.join(staging_dir, 'content', esri_filename))
      described_class.new.perform("druid:#{druid}")
      expect(File).not_to exist(File.join(staging_dir, 'content', esri_filename))
      expect(File.directory?(staging_dir)).to be false
    end
  end
end
