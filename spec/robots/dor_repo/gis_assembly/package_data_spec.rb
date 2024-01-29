# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::PackageData do
  let(:robot) { described_class.new }
  let(:bare_druid) { 'bb000dd1111' }
  let(:druid) { "druid:#{bare_druid}" }
  let(:rootdir) { GisRobotSuite.locate_druid_path(bare_druid, type: :stage) }
  let(:tmpdir) { File.join(rootdir, 'temp') }
  let(:data_zip_filepath) { GisRobotSuite.data_zip_filepath(rootdir, bare_druid) }

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
    before { FileUtils.rm_f(data_zip_filepath) }
    after { FileUtils.rm_f(data_zip_filepath) }

    it 'compresses files into data zip' do
      expect(File.exist?(data_zip_filepath)).to be false

      expect(data_zip_filepath).to eq 'spec/fixtures/stage/bb000dd1111/content/bb000dd1111.zip'
      expect(rootdir).to eq 'spec/fixtures/stage/bb000dd1111'

      robot.send(:generate_data_zip, rootdir, data_zip_filepath)

      expect(File.exist?(data_zip_filepath)).to be true
      expect(File.size(data_zip_filepath)).to eq 163_510
    end
  end
end
