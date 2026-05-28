# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisDerivative::CreateDerivatives do
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
      structural: { contains: files }
    )
  end
  let(:files) { [master_file] }
  let(:master_file) do
    Cocina::Models::File.new(
      type: 'https://cocina.sul.stanford.edu/models/file',
      externalIdentifier: 'https://cocina.sul.stanford.edu/file/vz757hs1282-vz757hs1282_1/data.tif',
      label: 'data.tif',
      filename: 'data.tif',
      size: 100,
      version: 2,
      hasMimeType: 'image/tiff; application=geotiff',
      use: 'master',
      administrative: {
        publish: true,
        sdrPreserve: true,
        shelve: true
      }
    )
  end
  let(:cocina_object) { build(:dro, id: druid).new(structural: structural, access: { view: 'world' }) }
  let(:object_client) do
    instance_double(Dor::Services::Client::Object, find: cocina_object, update: true)
  end
  let(:workspace_path) { Pathname.new(Settings.geohydra.workspace) / 'bb' / '222' / 'cc' / '3333' / 'bb222cc3333' / 'content' }
  let(:master_file_path) { workspace_path / 'data.tif' }
  let(:cog_file_path) { workspace_path / 'data_cog.tif' }

  before do
    allow(robot).to receive(:druid).and_return(druid)
    allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    allow(GisRobotSuite).to receive(:locate_druid_path).and_return(workspace_path.parent)
    allow(GisRobotSuite).to receive(:run_system_command)
    workspace_path.mkpath
    File.write(master_file_path, 'fake content')
    # This exists because we're stubbing out the call to `gdal raster convert'
    File.write(cog_file_path, 'fake cog content')
  end

  after do
    FileUtils.rm_f(master_file_path)
    FileUtils.rm_f(cog_file_path)
  end

  it 'creates a derivative COG' do
    perform
    expect(GisRobotSuite).to have_received(:run_system_command).with(/gdal raster convert --format=COG/, any_args)
    expect(object_client).to have_received(:update)
  end

  context 'when the derivative already exists in cocina' do
    let(:files) { [master_file, derivative_file] }

    let(:derivative_file) do
      Cocina::Models::File.new(
        type: 'https://cocina.sul.stanford.edu/models/file',
        externalIdentifier: 'https://cocina.sul.stanford.edu/file/vz757hs1282-vz757hs1282_1/data_cog.tif',
        label: 'data_cog.tif',
        filename: 'data_cog.tif',
        size: 50,
        version: 2,
        hasMimeType: 'image/tiff; application=geotiff; profile=cloud-optimized',
        use: 'derivative',
        administrative: {
          publish: true,
          sdrPreserve: false,
          shelve: true
        }
      )
    end

    it 'replaces the derivative' do
      perform
      expect(GisRobotSuite).to have_received(:run_system_command).with(/gdal raster convert --format=COG/, any_args)
      expect(object_client).to have_received(:update) do |params:|
        new_contains = params.structural.contains.first.structural.contains
        expect(new_contains.count).to eq 2
        expect(new_contains.map(&:use)).to eq %w[master derivative]
        # Ensure the old derivative was removed and a new one added (new externalIdentifier)
        expect(new_contains.find { |f| f.use == 'derivative' }.externalIdentifier).not_to eq derivative_file.externalIdentifier
      end
    end
  end

  context 'when the master file is missing from the workspace' do
    before do
      FileUtils.rm(workspace_path / 'data.tif')
    end

    it 'raises an error' do
      expect { perform }.to raise_error(NotImplementedError, /Unabel to find data.tif in the workspace/)
    end
  end

  context 'when there are non-master files' do
    let(:master_file) do
      Cocina::Models::File.new(
        type: 'https://cocina.sul.stanford.edu/models/file',
        externalIdentifier: 'https://cocina.sul.stanford.edu/file/vz757hs1282-vz757hs1282_1/data.tif',
        label: 'data.tif',
        filename: 'data.tif',
        size: 100,
        version: 2,
        hasMimeType: 'image/tiff',
        use: 'master',
        administrative: {
          publish: true,
          sdrPreserve: false, # Not preserved
          shelve: true
        }
      )
    end

    it 'skips them' do
      perform
      expect(GisRobotSuite).not_to have_received(:run_system_command)
    end
  end
end
