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
  let(:jp2_file_path) { workspace_path / 'data.jp2' }

  before do
    allow(robot).to receive(:druid).and_return(druid)
    allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    allow(GisRobotSuite).to receive(:locate_druid_path).and_return(workspace_path.parent)
    allow(GisRobotSuite).to receive(:run_system_command)
    allow(GisRobotSuite).to receive(:run_system_command).with(/gdalinfo -json/, any_args)
      .and_return({ stdout_str: '{"size": [1024, 768]}' })
    workspace_path.mkpath
    File.write(master_file_path, 'fake content')
    # This exists because we're stubbing out the call to `gdal raster convert'
    File.write(cog_file_path, 'fake cog content')
    File.write(jp2_file_path, 'fake jp2 content')
  end

  after do
    FileUtils.rm_f(master_file_path)
    FileUtils.rm_f(cog_file_path)
    FileUtils.rm_f(jp2_file_path)
  end

  it 'creates a derivative COG and a JP2 thumbnail' do
    perform
    expect(GisRobotSuite).to have_received(:run_system_command).with(/gdal raster convert --format=COG/, any_args)
    expect(GisRobotSuite).to have_received(:run_system_command).with(/gdal convert/, any_args)
    expect(object_client).to have_received(:update) do |params:|
      new_contains = params.structural.contains.first.structural.contains
      expect(new_contains.count).to eq 3
      expect(new_contains.map(&:use)).to eq %w[master derivative thumbnail]
      jp2_file = new_contains.find { |f| f.use == 'thumbnail' }
      expect(jp2_file.hasMimeType).to eq 'image/jp2'
      expect(jp2_file.presentation.height).to eq 768
      expect(jp2_file.presentation.width).to eq 1024
    end
  end

  context 'when shapefile' do
    let(:master_file) do
      Cocina::Models::File.new(
        type: 'https://cocina.sul.stanford.edu/models/file',
        externalIdentifier: 'https://cocina.sul.stanford.edu/file/vz757hs1282-vz757hs1282_1/data.shp',
        label: 'data.shp',
        filename: 'data.shp',
        size: 100,
        version: 2,
        hasMimeType: 'application/vnd.shp',
        use: 'master',
        administrative: {
          publish: true,
          sdrPreserve: true,
          shelve: true
        }
      )
    end
    let(:master_file_path) { workspace_path / 'data.shp' }
    let(:fgb_file_path) { workspace_path / 'data.fgb' }
    let(:pmtiles_file_path) { workspace_path / 'data.pmtiles' }
    let(:jp2_file_path) { workspace_path / 'data.jp2' }

    before do
      File.write(fgb_file_path, 'fake fgb content')
      File.write(pmtiles_file_path, 'fake pmtiles content')
      File.write(jp2_file_path, 'fake jp2 content')
    end

    after do
      FileUtils.rm_f(fgb_file_path)
      FileUtils.rm_f(pmtiles_file_path)
      FileUtils.rm_f(jp2_file_path)
    end

    it 'creates a derivative FGB, PMTiles, and a JP2 thumbnail' do
      perform
      expect(GisRobotSuite).to have_received(:run_system_command).with(/gdal vector convert --output-format 'FlatGeoBuf'/, any_args)
      expect(GisRobotSuite).to have_received(:run_system_command).with(/gdal vector reproject --dst-crs=EPSG:4326/, any_args)
      expect(GisRobotSuite).to have_received(:run_system_command).with(/tippecanoe -o .* -zg .* --drop-densest-as-needed --extend-zooms-if-still-dropping/, any_args)
      expect(GisRobotSuite).to have_received(:run_system_command).with(/gdal vector rasterize --size 512,512 --burn 255 --ot Byte/, any_args)
      expect(GisRobotSuite).to have_received(:run_system_command).with(/gdal convert/, any_args)
      expect(object_client).to have_received(:update) do |params:|
        new_contains = params.structural.contains.first.structural.contains
        expect(new_contains.count).to eq 4
        expect(new_contains.map(&:use)).to eq %w[master derivative derivative thumbnail]
        expect(new_contains.map(&:hasMimeType)).to contain_exactly('application/vnd.shp', 'application/vnd.fgb', 'application/vnd.pmtiles', 'image/jp2')
        jp2_file = new_contains.find { |f| f.use == 'thumbnail' }
        expect(jp2_file.presentation.height).to eq 768
        expect(jp2_file.presentation.width).to eq 1024
      end
    end

    context 'when the derivatives already exist in cocina' do
      let(:files) { [master_file, derivative_fgb_file, derivative_pmtiles_file] }

      let(:derivative_fgb_file) do
        Cocina::Models::File.new(
          type: 'https://cocina.sul.stanford.edu/models/file',
          externalIdentifier: 'https://cocina.sul.stanford.edu/file/vz757hs1282-vz757hs1282_1/data.fgb',
          label: 'data.fgb',
          filename: 'data.fgb',
          size: 50,
          version: 2,
          hasMimeType: 'application/vnd.fgb',
          use: 'derivative',
          administrative: { publish: true, sdrPreserve: false, shelve: true }
        )
      end

      let(:derivative_pmtiles_file) do
        Cocina::Models::File.new(
          type: 'https://cocina.sul.stanford.edu/models/file',
          externalIdentifier: 'https://cocina.sul.stanford.edu/file/vz757hs1282-vz757hs1282_1/data.pmtiles',
          label: 'data.pmtiles',
          filename: 'data.pmtiles',
          size: 50,
          version: 2,
          hasMimeType: 'application/vnd.pmtiles',
          use: 'derivative',
          administrative: { publish: true, sdrPreserve: false, shelve: true }
        )
      end

      it 'replaces all derivatives' do
        perform
        expect(GisRobotSuite).to have_received(:run_system_command).with(/gdal vector convert --output-format 'FlatGeoBuf'/, any_args)
        expect(GisRobotSuite).to have_received(:run_system_command).with(/gdal vector reproject --dst-crs=EPSG:4326/, any_args)
        expect(GisRobotSuite).to have_received(:run_system_command).with(/tippecanoe -o .* -zg .* --drop-densest-as-needed --extend-zooms-if-still-dropping/, any_args)
        expect(GisRobotSuite).to have_received(:run_system_command).with(/gdal vector rasterize --size 512,512 --burn 255 --ot Byte/, any_args)
        expect(GisRobotSuite).to have_received(:run_system_command).with(/gdal convert/, any_args)
        expect(object_client).to have_received(:update) do |params:|
          new_contains = params.structural.contains.first.structural.contains
          expect(new_contains.count).to eq 4
          # Ensure the old derivatives were removed and new ones added
          expect(new_contains.count { |f| f.use == 'derivative' }).to eq 2
          expect(new_contains.count { |f| f.use == 'thumbnail' }).to eq 1
          derivatives = new_contains.select { |f| f.use == 'derivative' }
          expect(derivatives.map(&:externalIdentifier)).not_to include(derivative_fgb_file.externalIdentifier)
          expect(derivatives.map(&:externalIdentifier)).not_to include(derivative_pmtiles_file.externalIdentifier)
          expect(derivatives.map(&:hasMimeType)).to contain_exactly('application/vnd.fgb', 'application/vnd.pmtiles')
          expect(new_contains.find { |f| f.use == 'thumbnail' }.hasMimeType).to eq 'image/jp2'
        end
      end
    end
  end

  context 'when geojson' do
    let(:master_file) do
      Cocina::Models::File.new(
        type: 'https://cocina.sul.stanford.edu/models/file',
        externalIdentifier: 'https://cocina.sul.stanford.edu/file/vz757hs1282-vz757hs1282_1/data.geojson',
        label: 'data.geojson',
        filename: 'data.geojson',
        size: 100,
        version: 2,
        hasMimeType: 'application/geo+json',
        use: 'master',
        administrative: {
          publish: true,
          sdrPreserve: true,
          shelve: true
        }
      )
    end
    let(:master_file_path) { workspace_path / 'data.geojson' }
    let(:fgb_file_path) { workspace_path / 'data.fgb' }
    let(:pmtiles_file_path) { workspace_path / 'data.pmtiles' }

    before do
      File.write(fgb_file_path, 'fake fgb content')
      File.write(pmtiles_file_path, 'fake pmtiles content')
    end

    after do
      FileUtils.rm_f(fgb_file_path)
      FileUtils.rm_f(pmtiles_file_path)
    end

    it 'creates derivatives' do
      perform
      expect(GisRobotSuite).to have_received(:run_system_command).with(/gdal vector convert --output-format 'FlatGeoBuf'/, any_args)
      expect(GisRobotSuite).to have_received(:run_system_command).with(/gdal vector reproject --dst-crs=EPSG:4326/, any_args)
      expect(GisRobotSuite).to have_received(:run_system_command).with(/tippecanoe -o .* -zg .* --drop-densest-as-needed --extend-zooms-if-still-dropping/, any_args)
      expect(GisRobotSuite).to have_received(:run_system_command).with(/gdal vector rasterize --size 512,512 --burn 255 --ot Byte/, any_args)
      expect(GisRobotSuite).to have_received(:run_system_command).with(/gdal convert/, any_args)
    end
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

    it 'replaces the derivative and adds a thumbnail' do
      perform
      expect(GisRobotSuite).to have_received(:run_system_command).with(/gdal raster convert --format=COG/, any_args)
      expect(GisRobotSuite).to have_received(:run_system_command).with(/gdal convert/, any_args)
      expect(object_client).to have_received(:update) do |params:|
        new_contains = params.structural.contains.first.structural.contains
        expect(new_contains.count).to eq 3
        expect(new_contains.map(&:use)).to eq %w[master derivative thumbnail]
        # Ensure the old derivative was removed and a new one added (new externalIdentifier)
        expect(new_contains.find { |f| f.hasMimeType.include?('profile=cloud-optimized') }.externalIdentifier).not_to eq derivative_file.externalIdentifier
      end
    end
  end

  context 'when the master file is missing from the workspace' do
    before do
      FileUtils.rm(workspace_path / 'data.tif')
    end

    it 'raises an error' do
      expect { perform }.to raise_error(NotImplementedError, /Unable to find data.tif in the workspace/)
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
