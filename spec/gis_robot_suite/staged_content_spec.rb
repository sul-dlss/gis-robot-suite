# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::StagedContent do
  let(:druid) { 'druid:bc123df4567' }
  let(:assembly_root) { Pathname(Dir.mktmpdir) }
  let(:stage_root) { Pathname(Dir.mktmpdir) }
  let(:assembly_pathname) { DruidTools::Druid.new(druid, assembly_root.to_s).pathname }
  let(:stage_pathname) { DruidTools::Druid.new(druid, stage_root.to_s).pathname }

  before do
    allow(Settings.geohydra).to receive_messages(assembly: assembly_root.to_s, stage: stage_root.to_s)
  end

  after do
    FileUtils.remove_entry(assembly_root)
    FileUtils.remove_entry(stage_root)
  end

  describe '.find' do
    context 'when the druid is in the assembly root' do
      before { assembly_pathname.mkpath }

      it 'returns the assembly content' do
        staged_content = described_class.find(druid)
        expect(staged_content).to be_assembly
        expect(staged_content).not_to be_staging
        expect(staged_content.pathname).to eq assembly_pathname
      end
    end

    context 'when the druid is in the staging root' do
      before { stage_pathname.mkpath }

      it 'returns the staging content' do
        staged_content = described_class.find(druid)
        expect(staged_content).to be_staging
        expect(staged_content).not_to be_assembly
        expect(staged_content.pathname).to eq stage_pathname
      end
    end

    context 'when the druid is in both roots' do
      before do
        assembly_pathname.mkpath
        stage_pathname.mkpath
      end

      it 'raises' do
        expect { described_class.find(druid) }.to raise_error(described_class::MultipleRootsError, /#{assembly_pathname}.*#{stage_pathname}/)
      end
    end

    context 'when the druid is in neither root' do
      it 'returns nil' do
        expect(described_class.find(druid)).to be_nil
      end
    end
  end

  describe '.find!' do
    context 'when the druid is in a root' do
      before { stage_pathname.mkpath }

      it 'returns the staged content' do
        expect(described_class.find!(druid).pathname).to eq stage_pathname
      end
    end

    context 'when the druid is in neither root' do
      it 'raises' do
        expect { described_class.find!(druid) }.to raise_error(described_class::NotFoundError, "No staged content for #{druid} in #{assembly_root} or #{stage_root}")
      end
    end
  end
end
