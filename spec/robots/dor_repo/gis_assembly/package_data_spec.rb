# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::PackageData do
  let(:robot) { described_class.new }
  let(:bare_druid) { 'bb000dd1111' }
  let(:druid) { "druid:#{bare_druid}" }
  let(:rootdir) { GisRobotSuite.locate_druid_path(bare_druid, type: :stage) }
  let(:tmpdir) { File.join(rootdir, 'temp') }
  let(:data_zip_filepath) { File.join(rootdir, 'content', 'data.zip') }

  before do
    allow(robot).to receive_messages(bare_druid:)
    allow(Settings.geohydra).to receive(:stage).and_return('spec/fixtures/stage')
  end

  describe '#perform_work' do
    before { allow(robot).to receive(:generate_data_zip) }

    context 'when the zip file already exists' do
      before do
        allow(File).to receive(:size?).with(data_zip_filepath).and_return(100)
      end

      it 'does not generate data zip file' do
        robot.perform_work

        expect(robot).not_to have_received(:generate_data_zip)
      end
    end

    context 'when the zip file does not exist' do
      before do
        allow(File).to receive(:size?).with(data_zip_filepath).and_return(nil)
      end

      it 'does not generate data zip file if it already exists' do
        robot.perform_work

        expect(robot).to have_received(:generate_data_zip)
      end
    end
  end

  describe '#generate_data_zip' do
    before do
      FileUtils.rm_f(data_zip_filepath)
      # The robot does not correctly reset the working directory.
      # This prevents that from leaking to other tests.
      # Reasonable attempts to fix this in the robot were unsuccessful.
      @pwd = Dir.pwd
    end

    after do
      FileUtils.rm_f(data_zip_filepath)
      Dir.chdir(@pwd) # rubocop:disable RSpec/InstanceVariable
    end

    it 'compresses files into data zip' do
      expect(File.exist?(data_zip_filepath)).to be false

      expect(data_zip_filepath).to eq 'spec/fixtures/stage/bb000dd1111/content/data.zip'
      expect(rootdir).to eq 'spec/fixtures/stage/bb000dd1111'

      robot.send(:generate_data_zip, rootdir)

      expect(File.exist?(data_zip_filepath)).to be true
      expect(File.size(data_zip_filepath)).to eq 163_510
    end
  end
end
