# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::StartGisAssemblyWorkflow do
  subject(:robot) { described_class.new }

  let(:druid) { 'druid:zz000zz0001' }
  let(:object_client) { instance_double(Dor::Services::Client::Object, version: version_client) }
  let(:version_client) do
    instance_double(Dor::Services::Client::ObjectVersion,
                    status: instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: version_open))
  end
  let(:version_open) { true }
  let(:cocina_object) do
    build(:dro, id: druid).new(
      structural: {
        contains: [
          Cocina::Models::FileSet.new(
            type: Cocina::Models::FileSetType.file,
            externalIdentifier: 'https://cocina.sul.stanford.edu/fileSet/zz000zz0001-1',
            label: 'Files',
            version: 1,
            structural: {
              contains: files
            }
          )
        ]
      },
      access: { view: 'world', download: 'world' }
    )
  end
  let(:files) do
    [
      Cocina::Models::File.new(
        type: 'https://cocina.sul.stanford.edu/models/file',
        externalIdentifier: 'https://cocina.sul.stanford.edu/file/zz000zz0001-1',
        label: 'metadata.xml',
        filename: 'metadata.xml',
        version: 1,
        hasMimeType: 'application/xml',
        administrative: { publish: true, sdrPreserve: true, shelve: true },
        access: { view: 'world', download: 'world' },
        hasMessageDigests: []
      )
    ]
  end

  before do
    allow(Dor::Services::Client).to receive(:object).with(druid).and_return(object_client)
    allow(object_client).to receive_messages(find: cocina_object, update: true)
  end

  describe '#perform' do
    subject(:perform) { test_perform(robot, druid) }

    it 'does not raise an error' do
      expect { perform }.not_to raise_error
    end

    it 'does not update the object when it has no image/tiff files' do
      perform

      expect(object_client).not_to have_received(:update)
    end

    context 'when the object has an image/tiff file' do
      let(:files) do
        super() + [
          Cocina::Models::File.new(
            type: 'https://cocina.sul.stanford.edu/models/file',
            externalIdentifier: 'https://cocina.sul.stanford.edu/file/zz000zz0001-2',
            label: 'map.tif',
            filename: 'map.tif',
            version: 1,
            hasMimeType: 'image/tiff',
            administrative: { publish: true, sdrPreserve: true, shelve: true },
            access: { view: 'world', download: 'world' },
            hasMessageDigests: []
          )
        ]
      end

      it 'updates the TIFF mimetype and preserves other mimetypes' do
        perform

        expect(object_client).to have_received(:update) do |params:|
          updated_files = params.structural.contains.first.structural.contains

          expect(updated_files.map(&:hasMimeType)).to eq(
            ['application/xml', 'image/tiff; application=geotiff']
          )
        end
      end
    end

    context 'when object is not open' do
      let(:version_open) { false }

      it 'raises an error' do
        expect { perform }.to raise_error 'GIS assembly has been started with an object that is not open'
      end
    end
  end
end
