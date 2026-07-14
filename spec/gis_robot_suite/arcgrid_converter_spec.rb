# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::ArcgridConverter do
  let(:druid) { 'druid:bb045mm1234' }
  let(:logger) { instance_double(Logger, debug: nil, info: nil, error: nil) }
  let(:object_client) { instance_double(Dor::Services::Client::Object, find: cocina_object, update: true) }
  let(:workspace_dir) { Pathname(Dir.mktmpdir) }
  let(:content_dir) { workspace_dir / 'content' }
  let(:grid_dir) { content_dir / 'elevation_grid' }

  let(:file_set) do
    Cocina::Models::FileSet.new(
      type: 'https://cocina.sul.stanford.edu/models/resources/object',
      externalIdentifier: 'https://cocina.sul.stanford.edu/fileset/1',
      label: 'Object',
      version: 3,
      structural: {
        contains: [
          cocina_file(filename: 'hdr.adf'),
          cocina_file(filename: 'w001001.adf'),
          cocina_file(filename: 'metadata.xml'),
          cocina_file(filename: 'metadata-iso19139.xml', mimetype: 'application/xml')
        ]
      }
    )
  end

  let(:cocina_object) do
    build(:dro, id: druid).new(
      structural: { contains: [file_set] },
      access: { view: 'world', download: 'world' },
      version: 3
    )
  end

  def cocina_file(filename:, mimetype: 'application/octet-stream')
    {
      type: 'https://cocina.sul.stanford.edu/models/file',
      externalIdentifier: "https://cocina.sul.stanford.edu/file/#{filename}",
      label: filename,
      filename: filename,
      version: 3,
      hasMimeType: mimetype,
      use: 'master',
      administrative: { publish: true, sdrPreserve: true, shelve: true },
      access: { view: 'world', download: 'world' },
      hasMessageDigests: []
    }
  end

  before do
    grid_dir.mkpath
    (grid_dir / 'hdr.adf').binwrite('header')
    (grid_dir / 'w001001.adf').binwrite('grid data')
    (grid_dir / 'metadata.xml').write('<metadata/>')

    allow(Dor::Services::Client).to receive(:object).with(druid).and_return(object_client)
    allow(object_client).to receive(:version)
    allow(GisRobotSuite).to receive(:locate_druid_path).with('bb045mm1234', type: :stage).and_return(workspace_dir.to_s)
    allow(GisRobotSuite).to receive(:run_system_command) do |_command, **|
      (content_dir / 'elevation_grid.tif').binwrite('geotiff')
      (content_dir / 'elevation_grid.tfw').write('world file')
    end
  end

  after do
    FileUtils.remove_entry(workspace_dir)
  end

  describe '.run' do
    it 'converts the ArcGRID and updates Cocina without managing the version' do
      described_class.run(druid:, logger:)

      expect(GisRobotSuite).to have_received(:run_system_command) do |command, logger:|
        expect(command).to include('gdal_translate', '-of GTiff', '-co COMPRESS\\=LZW', '-co TFW\\=YES')
        expect(command).to include(grid_dir.to_s, (content_dir / 'elevation_grid.tif').to_s)
        expect(logger).to eq(self.logger)
      end
      expect(content_dir / 'elevation_grid.tif.xml').to be_file
      expect((content_dir / 'elevation_grid.tif.xml').read).to eq('<metadata/>')
      expect(object_client).to have_received(:update) do |params:|
        files = params.structural.contains.first.structural.contains
        expect(files.map(&:filename)).to contain_exactly('elevation_grid.tif.xml', 'metadata-iso19139.xml', 'elevation_grid.tif', 'elevation_grid.tfw')

        geotiff = files.find { |file| file.filename == 'elevation_grid.tif' }
        expect(geotiff.hasMimeType).to eq('image/tiff; application=geotiff')
        expect(geotiff.size).to eq(7)
        expect(geotiff.hasMessageDigests.map(&:type)).to contain_exactly('sha1', 'md5')

        mimetypes = files.to_h { |file| [file.filename, file.hasMimeType] }
        expect(mimetypes).to include('elevation_grid.tif.xml' => 'application/xml', 'elevation_grid.tfw' => 'text/plain')
      end
      expect(object_client).not_to have_received(:version)
    end

    context 'when there is no ArcGRID' do
      before do
        FileUtils.rm_rf(grid_dir)
      end

      it 'raises without updating Cocina' do
        expect { described_class.run(druid:, logger:) }.to raise_error(RuntimeError, /No ArcGRID found/)

        expect(GisRobotSuite).not_to have_received(:run_system_command)
        expect(object_client).not_to have_received(:update)
      end
    end
  end
end
