# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisDelivery::MetadataCleanup do
  let(:workflow_client) { instance_double(Dor::Workflow::Client) }
  let(:source_druid) { 'cv676dy5796' }
  let(:source_dir) { File.join(DruidTools::Druid.new(source_druid, File.join(fixture_dir, 'stage')).path, 'content') }
  let(:staging_dir) { DruidTools::Druid.new(druid, File.join(fixture_dir, 'stage')).path }

  before do
    FileUtils.mkdir_p(staging_dir)
    FileUtils.cp_r(source_dir, staging_dir)
    allow(LyberCore::WorkflowClientFactory).to receive(:build).and_return(workflow_client)
    allow(workflow_client).to receive(:workflow_status).and_return('queued')
    allow(workflow_client).to receive(:update_status)
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
