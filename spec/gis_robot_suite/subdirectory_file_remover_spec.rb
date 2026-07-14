# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::SubdirectoryFileRemover do
  let(:druid) { 'druid:bd094kc8055' }
  let(:logger) { instance_double(Logger, info: nil, error: nil) }
  let(:object_client) { instance_double(Dor::Services::Client::Object) }
  let(:content_path) { File.join(fixture_dir, 'workspace', 'bd094kc8055', 'content') }
  let(:file_set) do
    Cocina::Models::FileSet.new(
      type: Cocina::Models::FileSetType.file,
      externalIdentifier: 'https://cocina.sul.stanford.edu/fileSet/1',
      label: 'Files',
      version: 1,
      structural: {
        contains: [
          cocina_file(filename: 'map.shp', id: 1),
          cocina_file(filename: 'lakes.gdb/a00000001.gdbtable', id: 2),
          cocina_file(filename: 'missing.txt', id: 3)
        ]
      }
    )
  end
  let(:cocina_object) do
    build(:dro, id: druid).new(
      structural: { contains: [file_set] },
      access: { view: 'world', download: 'world' },
      version: 1
    )
  end

  before do
    allow(GisRobotSuite).to receive(:locate_druid_path).with('bd094kc8055', type: :workspace)
                                                       .and_return(File.dirname(content_path))
    allow(File).to receive(:directory?).and_call_original
    allow(File).to receive(:directory?).with(content_path).and_return(true)
    allow(Dir).to receive(:children).and_call_original
    allow(Dir).to receive(:children).with(content_path).and_return(['map.shp', 'lakes.gdb'])
    allow(File).to receive(:file?).and_call_original
    allow(File).to receive(:file?).with(File.join(content_path, 'map.shp')).and_return(true)
    allow(File).to receive(:file?).with(File.join(content_path, 'lakes.gdb')).and_return(false)
    allow(Dor::Services::Client).to receive(:object).with(druid).and_return(object_client)
    allow(object_client).to receive_messages(find: cocina_object, update: true, version: nil)
  end

  describe '.run' do
    it 'instantiates the class and runs' do
      remover = instance_double(described_class, run: nil)
      allow(described_class).to receive(:new).with(logger:).and_return(remover)

      described_class.run(druid:, logger:)

      expect(remover).to have_received(:run).with(druid:)
    end
  end

  describe '#run' do
    it 'retains only Cocina files present directly in the content directory' do
      described_class.run(druid:, logger:)

      expect(object_client).to have_received(:update) do |params:|
        files = params.structural.contains.flat_map { |updated_file_set| updated_file_set.structural.contains }
        expect(files.map(&:filename)).to eq(['map.shp'])
      end
    end

    it 'does not open or close a version' do
      described_class.run(druid:, logger:)

      expect(object_client).not_to have_received(:version)
    end

    context 'when Cocina already contains only direct files' do
      let(:file_set) do
        Cocina::Models::FileSet.new(
          type: Cocina::Models::FileSetType.file,
          externalIdentifier: 'https://cocina.sul.stanford.edu/fileSet/1',
          label: 'Files',
          version: 1,
          structural: { contains: [cocina_file(filename: 'map.shp', id: 1)] }
        )
      end

      it 'does not save an unchanged object' do
        described_class.run(druid:, logger:)

        expect(object_client).not_to have_received(:update)
      end
    end

    context 'when the content directory is missing' do
      before do
        allow(File).to receive(:directory?).with(content_path).and_return(false)
      end

      it 'raises without retrieving or changing Cocina' do
        expect { described_class.run(druid:, logger:) }.to raise_error("Missing #{content_path}")

        expect(object_client).not_to have_received(:find)
        expect(object_client).not_to have_received(:update)
      end
    end
  end

  def cocina_file(filename:, id:)
    Cocina::Models::File.new(
      type: 'https://cocina.sul.stanford.edu/models/file',
      externalIdentifier: "https://cocina.sul.stanford.edu/file/#{id}",
      label: filename,
      filename:,
      version: 1,
      hasMimeType: 'application/octet-stream',
      use: 'master',
      administrative: { publish: true, sdrPreserve: true, shelve: true },
      access: { view: 'world', download: 'world' },
      hasMessageDigests: []
    )
  end
end
