# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::FinishGisAssemblyWorkflow do
  let(:robot) { described_class.new }
  let(:bare_druid) { 'bb045mm1234' }
  let(:druid) { "druid:#{bare_druid}" }
  let(:rootdir) { DruidTools::Druid.new(bare_druid, Settings.geohydra.stage).path }
  let(:tmpdir) { "#{rootdir}/temp" }
  let(:destdir) { GisRobotSuite.locate_druid_path bare_druid, type: :workspace }

  describe '#perform_work' do
    context 'when the content is in the staging root' do
      before do
        FileUtils.mkdir_p(tmpdir) unless File.directory?(tmpdir) # make a temp directory to be deleted
        allow(FileUtils).to receive(:rm_rf) # don't actually delete the fixtures in tests!
      end

      after do
        FileUtils.rm_r(destdir) if File.directory?(destdir)
      end

      it 'copies object to destination directory' do
        expect(count_files("#{rootdir}/content")).to eq 2 # 2 files in root content directory
        expect(File.directory?(destdir)).to be false # no dest directory yet
        expect(File.directory?(tmpdir)).to be true # temp directory exists
        test_perform(robot, bare_druid)
        expect(File.directory?(destdir)).to be true # dest directory created
        expect(count_files("#{destdir}/content")).to eq 2 # 2 files copied to dest content directory
      end

      it 'removes the staging area after the copy' do
        test_perform(robot, bare_druid)
        expect(FileUtils).to have_received(:rm_rf).with(rootdir)
      end
    end

    context 'when the content is in the assembly root' do
      let(:assembly_root) { Pathname(Dir.mktmpdir) }
      let(:assembly_dir) { DruidTools::Druid.new(bare_druid, assembly_root.to_s).pathname }
      let(:stage_root) { Pathname(Dir.mktmpdir) }

      before do
        allow(Settings.geohydra).to receive_messages(assembly: assembly_root.to_s, stage: stage_root.to_s)
        (assembly_dir / 'content').mkpath
        (assembly_dir / 'content' / 'data.shp').write('shapefile')
      end

      after do
        FileUtils.rm_r(destdir) if File.directory?(destdir)
        FileUtils.remove_entry(assembly_root)
        FileUtils.remove_entry(stage_root)
      end

      it 'copies the object to the workspace and removes it from assembly' do
        test_perform(robot, bare_druid)
        expect(File.read("#{destdir}/content/data.shp")).to eq 'shapefile'
        expect(assembly_dir).not_to exist
      end
    end

    context 'when the content is in both roots' do
      before do
        allow(Settings.geohydra).to receive(:assembly).and_return(Settings.geohydra.stage)
      end

      it 'raises' do
        expect { test_perform(robot, bare_druid) }.to raise_error(GisRobotSuite::StagedContent::MultipleRootsError)
      end
    end

    context 'when the content is in neither root' do
      let(:bare_druid) { 'zz999zz9999' }

      after do
        FileUtils.rm_r(destdir) if File.directory?(destdir)
      end

      it 'skips when the content is already in the workspace' do
        FileUtils.mkdir_p(destdir)
        expect(test_perform(robot, bare_druid)).to have_attributes(status: 'skipped', note: 'no staged content; already in workspace')
      end

      it 'raises when the content is not in the workspace' do
        expect { test_perform(robot, bare_druid) }.to raise_error(RuntimeError, /No staged content for #{bare_druid}/)
      end
    end
  end
end
