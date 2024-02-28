# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::FinishGisAssemblyWorkflow do
  let(:robot) { described_class.new }
  let(:workflow_client) { instance_double(Dor::Workflow::Client) }
  let(:bare_druid) { 'bb045mm1234' }
  let(:druid) { "druid:#{bare_druid}" }
  let(:rootdir) { GisRobotSuite.locate_druid_path bare_druid, type: :stage }
  let(:tmpdir) { "#{rootdir}/temp" }
  let(:destdir) { GisRobotSuite.locate_druid_path bare_druid, type: :workspace }

  before do
    allow(LyberCore::WorkflowClientFactory).to receive(:build).and_return(workflow_client)
    FileUtils.mkdir_p(tmpdir) unless File.directory?(tmpdir) # make a temp directory to be deleted
  end

  after do
    FileUtils.cp_r(destdir, Settings.geohydra.stage) # put files back where they were into the source directory for the next run
    FileUtils.rm_r(destdir) if File.directory?(destdir) # remove dest directory
  end

  describe '#perform_work' do
    it 'moves object to destination directory' do
      expect(count_files("#{rootdir}/content")).to eq 2 # 2 files in root content directory
      expect(File.directory?(destdir)).to be false # no dest directory yet
      expect(File.directory?(tmpdir)).to be true # temp directory exists
      test_perform(robot, bare_druid)
      expect(File.directory?(tmpdir)).to be false # temp directory deleted
      expect(File.directory?(destdir)).to be true # dest directory created
      expect(count_files("#{destdir}/content")).to eq 2 # 2 files moved to dest content directory
      expect(File.directory?(rootdir)).to be false # root directory removed
    end
  end
end
