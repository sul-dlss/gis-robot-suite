# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::StructuralMetadataBuilder do
  describe '.build' do
    subject(:result) { described_class.build(cocina_model, druid, objects) }

    let(:item) { Dor::Assembly::Item.new(druid: druid) }
    let(:cocina_model) { build(:dro, id: druid).new(structural: structural) }
    let(:druid) { 'druid:bb222cc3333' }

    let(:structural) do
      { contains: [{ type: 'https://cocina.sul.stanford.edu/models/resources/image',
                     externalIdentifier: 'bb111bb2222_1',
                     label: 'Image 1',
                     version: 1,
                     structural: { contains: [{ type: 'https://cocina.sul.stanford.edu/models/file',
                                                externalIdentifier: 'https://cocina.sul.stanford.edu/file/adb98474-98a6-4f12-bef8-3ffb249153b1',
                                                label: 'image111.tif',
                                                filename: 'image111.tif',
                                                size: 0,
                                                version: 1,
                                                hasMessageDigests: [{ type: 'md5', digest: '42616f9e6c1b7e7b7a71b4fa0c5ef794' }],
                                                access: { view: 'dark', download: 'none', controlledDigitalLending: false },
                                                administrative: { publish: false, sdrPreserve: true, shelve: false } }] } },
                   { type: 'https://cocina.sul.stanford.edu/models/resources/image',
                     externalIdentifier: 'bb111bb2222_2',
                     label: 'Image 2',
                     version: 1,
                     structural: { contains: [{ type: 'https://cocina.sul.stanford.edu/models/file',
                                                externalIdentifier: 'https://cocina.sul.stanford.edu/file/f76ee0bc-45d2-4989-b76f-9b973d773e39',
                                                label: 'image112.tif',
                                                filename: 'image112.tif',
                                                size: 0,
                                                version: 1,
                                                hasMessageDigests: [{ type: 'sha1', digest: '5c9f6dc2ca4fd3329619b54a2c6f99a08c088444' },
                                                                    { type: 'md5', digest: 'ac440802bd590ce0899dafecc5a5ab1b' }],
                                                access: { view: 'dark', download: 'none', controlledDigitalLending: false },
                                                administrative: { publish: false, sdrPreserve: true, shelve: false } }] } },
                   { type: 'https://cocina.sul.stanford.edu/models/resources/image',
                     externalIdentifier: 'bb111bb2222_3',
                     label: 'Image 3',
                     version: 1,
                     structural: { contains: [{ type: 'https://cocina.sul.stanford.edu/models/file',
                                                externalIdentifier: 'https://cocina.sul.stanford.edu/file/b63faebf-7204-4e3e-ae29-255315480add',
                                                label: 'sub/image113.tif',
                                                filename: 'sub/image113.tif',
                                                size: 0,
                                                version: 1,
                                                hasMessageDigests: [],
                                                access: { view: 'dark', download: 'none', controlledDigitalLending: false },
                                                administrative: { publish: false, sdrPreserve: true, shelve: false } }] } }],
        hasMemberOrders: [],
        isMemberOf: [] }
    end
    let(:objects) do
      {
        Data: [file1],
        Preview: [file2],
        Metadata: [file3]
      }
    end

    let(:file1) do
      instance_double(Assembly::ObjectFile, filename: 'data.zip', path: 'data.zip',
                                            mimetype: 'application/zip', filesize: 63_472, image?: false,
                                            sha1: 'aabbcc0000', md5: 'ddeeff0000')
    end
    let(:file2) do
      instance_double(Assembly::ObjectFile, filename: 'image.png', path: 'image.png',
                                            mimetype: 'image/png', filesize: 22_222, image?: true,
                                            sha1: 'aabbcc11111', md5: 'ddeeff1111')
    end
    let(:file3) do
      instance_double(Assembly::ObjectFile, filename: 'application.pdf', path: 'application.pdf',
                                            mimetype: 'application/pdf', filesize: 11_111, image?: false,
                                            sha1: 'aabbcc2222', md5: 'ddeeff2222')
    end

    before do
      allow(FastImage).to receive(:size).and_return([500, 700])
      allow(FastImage).to receive(:type).and_return(:png)
      allow(SecureRandom).to receive(:uuid).and_return(1, 2, 3)
    end

    it 'sets the size and mimetype' do
      expect(result.contains.map(&:to_h)).to eq [
        { type: 'https://cocina.sul.stanford.edu/models/resources/object',
          externalIdentifier: 'druid:bb222cc3333_1',
          label: 'Data',
          version: 1,
          structural: { contains: [{ type: 'https://cocina.sul.stanford.edu/models/file',
                                     externalIdentifier: 'https://cocina.sul.stanford.edu/file/1',
                                     label: 'data.zip',
                                     filename: 'data.zip',
                                     size: 63472,
                                     version: 1,
                                     hasMimeType: 'application/zip',
                                     use: 'master',
                                     hasMessageDigests: [{ type: 'sha1', digest: 'aabbcc0000' }, { type: 'md5', digest: 'ddeeff0000' }],
                                     access: { view: 'dark', download: 'none', controlledDigitalLending: false },
                                     administrative: { publish: true, sdrPreserve: true, shelve: true } }] } },
        { type: 'https://cocina.sul.stanford.edu/models/resources/preview',
          externalIdentifier: 'druid:bb222cc3333_2',
          label: 'Preview',
          version: 1,
          structural: { contains: [{ type: 'https://cocina.sul.stanford.edu/models/file',
                                     externalIdentifier: 'https://cocina.sul.stanford.edu/file/2',
                                     label: 'image.png',
                                     filename: 'image.png',
                                     size: 22222,
                                     version: 1,
                                     hasMimeType: 'image/png',
                                     use: 'master',
                                     hasMessageDigests: [{ type: 'sha1', digest: 'aabbcc11111' }, { type: 'md5', digest: 'ddeeff1111' }],
                                     access: { view: 'dark', download: 'none', controlledDigitalLending: false },
                                     administrative: { publish: true, sdrPreserve: true, shelve: true },
                                     presentation: { height: 700, width: 500 } }] } },
        { type: 'https://cocina.sul.stanford.edu/models/resources/attachment',
          externalIdentifier: 'druid:bb222cc3333_3',
          label: 'Metadata',
          version: 1,
          structural: { contains: [{ type: 'https://cocina.sul.stanford.edu/models/file',
                                     externalIdentifier: 'https://cocina.sul.stanford.edu/file/3',
                                     label: 'application.pdf',
                                     filename: 'application.pdf',
                                     size: 11111,
                                     version: 1,
                                     hasMimeType: 'application/pdf',
                                     use: 'master',
                                     hasMessageDigests: [{ type: 'sha1', digest: 'aabbcc2222' }, { type: 'md5', digest: 'ddeeff2222' }],
                                     access: { view: 'dark', download: 'none', controlledDigitalLending: false },
                                     administrative: { publish: true, sdrPreserve: false, shelve: true } }] } }
      ]
    end
  end
end
