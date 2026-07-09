# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::PreviewJpgRemover do
  let(:druid) { 'druid:bb045mm1234' }
  let(:logger) { instance_double(Logger, info: nil, error: nil) }
  let(:object_client) { instance_double(Dor::Services::Client::Object) }
  let(:version_client) { instance_double(Dor::Services::Client::ObjectVersion) }

  let(:file_set_with_preview) do
    Cocina::Models::FileSet.new(
      type: 'https://cocina.sul.stanford.edu/models/resources/object',
      externalIdentifier: 'https://cocina.sul.stanford.edu/fileset/1',
      label: 'Object',
      version: 1,
      structural: {
        contains: [
          {
            type: 'https://cocina.sul.stanford.edu/models/file',
            externalIdentifier: 'https://cocina.sul.stanford.edu/file/1',
            label: 'preview.jpg',
            filename: 'preview.jpg',
            version: 1,
            hasMimeType: 'image/jpeg',
            use: 'master',
            administrative: { publish: true, sdrPreserve: true, shelve: true },
            access: { view: 'world', download: 'world' },
            hasMessageDigests: []
          },
          {
            type: 'https://cocina.sul.stanford.edu/models/file',
            externalIdentifier: 'https://cocina.sul.stanford.edu/file/2',
            label: 'master.tif',
            filename: 'master.tif',
            version: 1,
            hasMimeType: 'image/tiff',
            use: 'master',
            administrative: { publish: true, sdrPreserve: true, shelve: true },
            access: { view: 'world', download: 'world' },
            hasMessageDigests: []
          }
        ]
      }
    )
  end

  let(:file_set_without_preview) do
    Cocina::Models::FileSet.new(
      type: 'https://cocina.sul.stanford.edu/models/resources/object',
      externalIdentifier: 'https://cocina.sul.stanford.edu/fileset/2',
      label: 'Object',
      version: 1,
      structural: {
        contains: [
          {
            type: 'https://cocina.sul.stanford.edu/models/file',
            externalIdentifier: 'https://cocina.sul.stanford.edu/file/3',
            label: 'master.tif',
            filename: 'master.tif',
            version: 1,
            hasMimeType: 'image/tiff',
            use: 'master',
            administrative: { publish: true, sdrPreserve: true, shelve: true },
            access: { view: 'world', download: 'world' },
            hasMessageDigests: []
          }
        ]
      }
    )
  end

  let(:file_set_extra) do
    Cocina::Models::FileSet.new(
      type: 'https://cocina.sul.stanford.edu/models/resources/object',
      externalIdentifier: 'https://cocina.sul.stanford.edu/fileset/3',
      label: 'Object',
      version: 1,
      structural: {
        contains: [
          {
            type: 'https://cocina.sul.stanford.edu/models/file',
            externalIdentifier: 'https://cocina.sul.stanford.edu/file/4',
            label: 'data.zip',
            filename: 'data.zip',
            version: 1,
            hasMimeType: 'application/zip',
            use: 'master',
            administrative: { publish: true, sdrPreserve: true, shelve: true },
            access: { view: 'world', download: 'world' },
            hasMessageDigests: []
          }
        ]
      }
    )
  end

  # Multiple file sets, and the first one contains the preview.jpg to be removed.
  let(:cocina_with_preview) do
    build(:dro, id: druid).new(
      structural: {
        contains: [file_set_with_preview, file_set_extra]
      },
      access: { view: 'world', download: 'world' },
      version: 1
    )
  end

  # A single file set with no preview.jpg: nothing to do.
  let(:cocina_without_preview) do
    build(:dro, id: druid).new(
      structural: {
        contains: [file_set_without_preview]
      },
      access: { view: 'world', download: 'world' },
      version: 1
    )
  end

  # Multiple file sets but no preview.jpg: still needs consolidating.
  let(:cocina_multiple_file_sets) do
    build(:dro, id: druid).new(
      structural: {
        contains: [file_set_without_preview, file_set_extra]
      },
      access: { view: 'world', download: 'world' },
      version: 1
    )
  end

  before do
    allow(Dor::Services::Client).to receive(:object).with(druid).and_return(object_client)
    allow(object_client).to receive_messages(version: version_client, update: true)
    allow(version_client).to receive(:close).and_return(true)
  end

  describe '.run' do
    it 'instantiates the class and runs' do
      remover_instance = instance_double(described_class, run: nil)
      allow(described_class).to receive(:new).with(logger: logger).and_return(remover_instance)

      described_class.run(druid: druid, logger: logger)
      expect(remover_instance).to have_received(:run).with(druid: druid)
    end
  end

  describe '#run' do
    context 'when the object has a preview.jpg file and multiple file sets' do
      before do
        allow(object_client).to receive(:find).and_return(cocina_with_preview)
        allow(version_client).to receive(:open).and_return(cocina_with_preview)
      end

      it 'removes preview.jpg and consolidates all files into a single file set' do
        described_class.run(druid: druid, logger: logger)

        expect(version_client).to have_received(:open).with(description: 'Remove preview.jpg and consolidate files into a single file set')
        expect(object_client).to have_received(:update) do |params:|
          file_sets = params.structural.contains

          expect(file_sets.size).to eq(1)

          filenames = file_sets.first.structural.contains.map(&:filename)
          expect(filenames).not_to include('preview.jpg')
          expect(filenames).to contain_exactly('master.tif', 'data.zip')
        end
        expect(version_client).to have_received(:close)
      end
    end

    context 'when the object has a single file set and no preview.jpg' do
      before do
        allow(object_client).to receive(:find).and_return(cocina_without_preview)
        allow(version_client).to receive(:open)
      end

      it 'skips version open and updating' do
        described_class.run(druid: druid, logger: logger)

        expect(version_client).not_to have_received(:open)
        expect(object_client).not_to have_received(:update)
        expect(version_client).not_to have_received(:close)
      end
    end

    context 'when the object has multiple file sets but no preview.jpg' do
      before do
        allow(object_client).to receive(:find).and_return(cocina_multiple_file_sets)
        allow(version_client).to receive(:open).and_return(cocina_multiple_file_sets)
      end

      it 'consolidates all files into a single file set' do
        described_class.run(druid: druid, logger: logger)

        expect(object_client).to have_received(:update) do |params:|
          file_sets = params.structural.contains

          expect(file_sets.size).to eq(1)
          expect(file_sets.first.structural.contains.map(&:filename)).to contain_exactly('master.tif', 'data.zip')
        end
        expect(version_client).to have_received(:close)
      end
    end

    context 'when an error is raised' do
      before do
        allow(object_client).to receive(:find).and_raise(StandardError.new('API error'))
      end

      it 'logs the error and re-raises' do
        expect do
          described_class.run(druid: druid, logger: logger)
        end.to raise_error(StandardError, 'API error')

        expect(logger).to have_received(:error).with('  Failed to process druid:bb045mm1234: API error')
      end
    end
  end
end
