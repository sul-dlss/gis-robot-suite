# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::OvrMimetypeUpdater do
  let(:druid) { 'druid:bb045mm1234' }
  let(:logger) { instance_double(Logger, info: nil, error: nil) }
  let(:object_client) { instance_double(Dor::Services::Client::Object) }
  let(:version_client) { instance_double(Dor::Services::Client::ObjectVersion) }
  let(:version_status) do
    instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: version_open)
  end
  let(:version_open) { false }

  let(:file_set) do
    Cocina::Models::FileSet.new(
      type: 'https://cocina.sul.stanford.edu/models/resources/object',
      externalIdentifier: 'https://cocina.sul.stanford.edu/fileset/1',
      label: 'Object',
      version: 1,
      structural: {
        contains: [
          cocina_file(filename: 'image.tif.ovr', mimetype: 'image/tiff'),
          cocina_file(filename: 'another.OVR', mimetype: 'text/plain', identifier: 'file/2'),
          cocina_file(filename: 'image.tif', mimetype: 'image/tiff', identifier: 'file/3')
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
    allow(Dor::Services::Client).to receive(:object).with(druid).and_return(object_client)
    allow(object_client).to receive_messages(find: cocina_object, version: version_client, update: true)
    allow(version_client).to receive_messages(status: version_status, open: cocina_object, close: true)
  end

  describe '.run' do
    it 'instantiates the class and runs' do
      updater = instance_double(described_class, run: nil)
      allow(described_class).to receive(:new).with(logger: logger).and_return(updater)

      described_class.run(druid: druid, logger: logger)

      expect(updater).to have_received(:run).with(druid: druid)
    end
  end

  describe '#run' do
    it 'sets the mimetype on every .ovr file and leaves other files unchanged' do
      described_class.run(druid: druid, logger: logger)

      expect(version_client).to have_received(:open)
        .with(description: 'Set .ovr file mimetype to application/octet-stream')
      expect(object_client).to have_received(:update) do |params:|
        mimetypes = params.structural.contains.first.structural.contains.to_h do |file|
          [file.filename, file.hasMimeType]
        end
        expect(mimetypes).to eq(
          'image.tif.ovr' => 'application/octet-stream',
          'another.OVR' => 'application/octet-stream',
          'image.tif' => 'image/tiff'
        )
      end
      expect(version_client).to have_received(:close)
    end

    context 'when a version is already open' do
      let(:version_open) { true }

      it 'updates the existing version without opening or closing it' do
        described_class.run(druid: druid, logger: logger)

        expect(version_client).not_to have_received(:open)
        expect(object_client).to have_received(:update) do |params:|
          ovr_file = params.structural.contains.first.structural.contains.first
          expect(ovr_file.hasMimeType).to eq('application/octet-stream')
        end
        expect(version_client).not_to have_received(:close)
      end
    end

    context 'when the object does not have an .ovr file' do
      let(:file_set) do
        Cocina::Models::FileSet.new(
          type: 'https://cocina.sul.stanford.edu/models/resources/object',
          externalIdentifier: 'https://cocina.sul.stanford.edu/fileset/1',
          label: 'Object',
          version: 1,
          structural: { contains: [cocina_file(filename: 'image.tif', mimetype: 'image/tiff')] }
        )
      end

      it 'does not open or update a version' do
        described_class.run(druid: druid, logger: logger)

        expect(version_client).not_to have_received(:status)
        expect(version_client).not_to have_received(:open)
        expect(object_client).not_to have_received(:update)
        expect(version_client).not_to have_received(:close)
      end
    end

    context 'when an error is raised' do
      before do
        allow(object_client).to receive(:find).and_raise(StandardError, 'API error')
      end

      it 'logs the error and re-raises' do
        expect { described_class.run(druid: druid, logger: logger) }.to raise_error(StandardError, 'API error')

        expect(logger).to have_received(:error).with('  Failed to process druid:bb045mm1234: API error')
      end
    end
  end

  def cocina_file(filename:, mimetype:, identifier: 'file/1')
    {
      type: 'https://cocina.sul.stanford.edu/models/file',
      externalIdentifier: "https://cocina.sul.stanford.edu/#{identifier}",
      label: filename,
      filename: filename,
      version: 1,
      hasMimeType: mimetype,
      administrative: { publish: true, sdrPreserve: true, shelve: true },
      access: { view: 'world', download: 'world' },
      hasMessageDigests: []
    }
  end
end
