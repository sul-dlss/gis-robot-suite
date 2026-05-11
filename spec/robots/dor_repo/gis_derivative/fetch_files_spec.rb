# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisDerivative::FetchFiles do
  subject(:perform) { test_perform(robot, druid) }

  let(:druid) { 'druid:bb222cc3333' }
  let(:robot) { described_class.new }
  let(:structural) do
    Cocina::Models::DROStructural.new({ contains: [
                                        fileset
                                      ] })
  end
  let(:fileset) do
    Cocina::Models::FileSet.new(
      type: 'https://cocina.sul.stanford.edu/models/resources/object',
      externalIdentifier: 'https://cocina.sul.stanford.edu/fileSet/vz757hs1282-vz757hs1282_1',
      label: 'Data',
      version: 2,
      structural: { contains: [
        data_file,
        also_data
      ] }
    )
  end
  let(:data_file) do
    Cocina::Models::File.new(
      type: 'https://cocina.sul.stanford.edu/models/file',
      externalIdentifier: 'https://cocina.sul.stanford.edu/file/vz757hs1282-vz757hs1282_1/data.zip',
      label: 'data.zip',
      filename: 'data.zip',
      size: 46_508_117,
      version: 2,
      hasMimeType: 'application/zip',
      use: 'master',
      administrative: {
        publish: true,
        sdrPreserve: true,
        shelve: true
      }
    )
  end
  let(:also_data) do
    Cocina::Models::File.new(filename: 'data2.zip',
                             label: 'data2.zip',
                             type: 'https://cocina.sul.stanford.edu/models/file',
                             externalIdentifier: 'https://cocina.sul.stanford.edu/file/vz757hs1282-vz757hs1282_1/data.zip',
                             size: 46_508_117,
                             version: 2,
                             hasMimeType: 'application/zip',
                             use: 'master',
                             administrative: {
                               publish: true,
                               sdrPreserve: true,
                               shelve: true
                             })
  end
  let(:cocina_model) { build(:dro, id: druid).new(structural: structural, type: object_type, access: { view: 'world' }) }
  let(:object_type) { Cocina::Models::ObjectType.geo }
  let(:file_fetcher) { instance_double(GisRobotSuite::FileFetcher, write_file_with_retries: fetch_success) }
  let(:fetch_success) { true }
  let(:object_client) do
    instance_double(Dor::Services::Client::Object, find: cocina_model, update: true)
  end
  let(:workspace_path) { Pathname.new(Settings.geohydra.workspace) / 'bb' / '222' / 'cc' / '3333' / 'bb222cc3333' / 'content' }

  before do
    allow(robot).to receive(:druid).and_return(druid)
    allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    allow(GisRobotSuite::FileFetcher).to receive(:new).and_return(file_fetcher)
  end

  after do
    FileUtils.rm_rf(File.join(Settings.geohydra.workspace, 'bb/222'))
  end

  context 'when fetching files is successful' do
    let(:fetch_success) { true }

    it 'calls the write_file_with_retries method with correct files' do
      expect(perform).to eq ['data.zip', 'data2.zip']
      expect(file_fetcher).to have_received(:write_file_with_retries)
        .with(filename: 'data.zip', location: workspace_path / 'data.zip', max_tries: 3)
      expect(file_fetcher).to have_received(:write_file_with_retries)
        .with(filename: 'data2.zip', location: workspace_path / 'data2.zip', max_tries: 3)
    end
  end

  context 'when fetching files fails' do
    let(:fetch_success) { false }

    it 'raises an exception' do
      expect { perform }.to raise_error(RuntimeError, 'Unable to fetch data.zip for druid:bb222cc3333')
      expect(file_fetcher).to have_received(:write_file_with_retries)
        .with(filename: 'data.zip', location: workspace_path / 'data.zip', max_tries: 3)
    end
  end
end
