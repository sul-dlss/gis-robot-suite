# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::GenerateStructural do
  describe '#perform_work' do
    let(:robot) { described_class.new }
    let(:cocina_model) do
      build(:dro, id: druid).new(
        structural: {
          contains: [],
          hasMemberOrders: [],
          isMemberOf: ['druid:rz415nf2825']
        },
        access: cocina_object_access
      )
    end
    let(:cocina_object_access) do
      {
        view: 'world',
        download: 'world',
        controlledDigitalLending: false
      }
    end

    let(:object_client) do
      instance_double(Dor::Services::Client::Object, find: cocina_model, update: true)
    end

    before do
      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
      allow(SecureRandom).to receive(:uuid).and_return('8222376b-861f-4cb1-8ebb-c2ae6b112b4e', 'ec13ab89-39b0-455d-8b2c-f6e1c9cc8e60', '0d896cd1-57e3-4fc1-93c0-dd0e37d4e65a')
    end

    context 'without an index map file' do
      let(:druid) { 'druid:cc044gt0726' }

      let(:expected_file_access) do
        {
          view: 'world',
          download: 'world',
          controlledDigitalLending: false
        }
      end

      let(:expected_structural) do
        {
          contains: [
            {
              type: 'https://cocina.sul.stanford.edu/models/resources/object',
              externalIdentifier: 'cc044gt0726_1',
              label: 'Data',
              version: 1,
              structural: {
                contains: [
                  {
                    type: 'https://cocina.sul.stanford.edu/models/file',
                    externalIdentifier: 'https://cocina.sul.stanford.edu/file/8222376b-861f-4cb1-8ebb-c2ae6b112b4e',
                    label: 'sanluisobispo1996.shp',
                    filename: 'sanluisobispo1996.shp',
                    size: 2951888,
                    version: 1,
                    hasMimeType: 'application/vnd.shp',
                    use: 'master',
                    hasMessageDigests: [
                      {
                        type: 'sha1',
                        digest: '9d2a6bb804485ecc5325d5abe95e62018a8d0ea6'
                      },
                      {
                        type: 'md5',
                        digest: 'cc6c2325c880aa9edcfde1634e4a336c'
                      }
                    ],
                    access: expected_file_access,
                    administrative: {
                      publish: true,
                      sdrPreserve: true,
                      shelve: true
                    }
                  },
                  {
                    type: 'https://cocina.sul.stanford.edu/models/file',
                    externalIdentifier: 'https://cocina.sul.stanford.edu/file/ec13ab89-39b0-455d-8b2c-f6e1c9cc8e60',
                    label: 'sanluisobispo1996.shx',
                    filename: 'sanluisobispo1996.shx',
                    size: 21900,
                    version: 1,
                    hasMimeType: 'application/vnd.shx',
                    use: 'master',
                    hasMessageDigests: [
                      {
                        type: 'sha1',
                        digest: '2a7b1065200b47a6e5241bf68261661e1c79906e'
                      },
                      {
                        type: 'md5',
                        digest: '89acab87c6ee451e7897b08f386c1d3a'
                      }
                    ],
                    access: expected_file_access,
                    administrative: {
                      publish: true,
                      sdrPreserve: true,
                      shelve: true
                    }
                  },
                  {
                    type: 'https://cocina.sul.stanford.edu/models/file',
                    externalIdentifier: 'https://cocina.sul.stanford.edu/file/0d896cd1-57e3-4fc1-93c0-dd0e37d4e65a',
                    label: 'sanluisobispo1996.dbf',
                    filename: 'sanluisobispo1996.dbf',
                    size: 270001,
                    version: 1,
                    hasMimeType: 'application/vnd.dbf',
                    use: 'master',
                    hasMessageDigests: [
                      {
                        type: 'sha1',
                        digest: '883c72c9eff436707e21d425e8950e95870d7151'
                      },
                      {
                        type: 'md5',
                        digest: '727a2c1ca5401f8f38da75ca38abdf1d'
                      }
                    ],
                    access: expected_file_access,
                    administrative: {
                      publish: true,
                      sdrPreserve: true,
                      shelve: true
                    }
                  },
                  {
                    type: 'https://cocina.sul.stanford.edu/models/file',
                    externalIdentifier: 'https://cocina.sul.stanford.edu/file/0d896cd1-57e3-4fc1-93c0-dd0e37d4e65a',
                    label: 'sanluisobispo1996.sbn',
                    filename: 'sanluisobispo1996.sbn',
                    size: 27300,
                    version: 1,
                    hasMimeType: 'application/octet-stream',
                    use: 'master',
                    hasMessageDigests: [
                      {
                        type: 'sha1',
                        digest: 'c07cb254d6f7b3f7a76397ffbdabe376a522279e'
                      },
                      {
                        type: 'md5',
                        digest: 'e2fe4c9d0478f5ef9923a3ec999521c2'
                      }
                    ],
                    access: expected_file_access,
                    administrative: {
                      publish: true,
                      sdrPreserve: true,
                      shelve: true
                    }
                  },
                  {
                    type: 'https://cocina.sul.stanford.edu/models/file',
                    externalIdentifier: 'https://cocina.sul.stanford.edu/file/0d896cd1-57e3-4fc1-93c0-dd0e37d4e65a',
                    label: 'sanluisobispo1996.prj',
                    filename: 'sanluisobispo1996.prj',
                    size: 469,
                    version: 1,
                    hasMimeType: 'text/plain',
                    use: 'master',
                    hasMessageDigests: [
                      {
                        type: 'sha1',
                        digest: '1732f86614fe403ef7079b59c822e8fe597d91b5'
                      },
                      {
                        type: 'md5',
                        digest: '9188c653628e3ed3ecd731e71461dbd7'
                      }
                    ],
                    access: expected_file_access,
                    administrative: {
                      publish: true,
                      sdrPreserve: true,
                      shelve: true
                    }
                  }
                ]
              }
            },
            {
              type: 'https://cocina.sul.stanford.edu/models/resources/preview',
              externalIdentifier: 'cc044gt0726_2',
              label: 'Preview',
              version: 1,
              structural: {
                contains: [
                  {
                    type: 'https://cocina.sul.stanford.edu/models/file',
                    externalIdentifier: 'https://cocina.sul.stanford.edu/file/0d896cd1-57e3-4fc1-93c0-dd0e37d4e65a',
                    label: 'preview.jpg',
                    filename: 'preview.jpg',
                    size: 5298,
                    version: 1,
                    hasMimeType: 'image/jpeg',
                    use: 'master',
                    hasMessageDigests: [
                      {
                        type: 'sha1',
                        digest: '3d2de8df05b13a953cbdf581045b7631e6d49d83'
                      },
                      {
                        type: 'md5',
                        digest: 'e60d57074eb3add590985781fdc8cf0c'
                      }
                    ],
                    access: expected_file_access,
                    administrative: {
                      publish: true,
                      sdrPreserve: true,
                      shelve: true
                    },
                    presentation: {
                      height: 133,
                      width: 200
                    }
                  }
                ]
              }
            },
            {
              type: 'https://cocina.sul.stanford.edu/models/resources/object',
              externalIdentifier: 'cc044gt0726_3',
              label: 'Metadata',
              version: 1,
              structural: {
                contains: [
                  {
                    type: 'https://cocina.sul.stanford.edu/models/file',
                    externalIdentifier: 'https://cocina.sul.stanford.edu/file/0d896cd1-57e3-4fc1-93c0-dd0e37d4e65a',
                    label: 'sanluisobispo1996.shp.xml',
                    filename: 'sanluisobispo1996.shp.xml',
                    size: 24684,
                    version: 1,
                    hasMimeType: 'application/xml',
                    use: 'master',
                    hasMessageDigests: [
                      {
                        type: 'sha1',
                        digest: '085bc84d3663505c9226ec51f612de5e7ca78d1d'
                      },
                      {
                        type: 'md5',
                        digest: '65269731824353b3ca3fab67ebdfd744'
                      }
                    ],
                    access: expected_file_access,
                    administrative: {
                      publish: true,
                      sdrPreserve: true,
                      shelve: true
                    }
                  },
                  {
                    type: 'https://cocina.sul.stanford.edu/models/file',
                    externalIdentifier: 'https://cocina.sul.stanford.edu/file/0d896cd1-57e3-4fc1-93c0-dd0e37d4e65a',
                    label: 'sanluisobispo1996-iso19139.xml',
                    filename: 'sanluisobispo1996-iso19139.xml',
                    size: 29062,
                    version: 1,
                    hasMimeType: 'application/xml',
                    use: 'derivative',
                    hasMessageDigests: [
                      {
                        type: 'sha1',
                        digest: 'e98a64922c138b1119de35e9b7543896e59596cb'
                      },
                      {
                        type: 'md5',
                        digest: '54200e1ae282abce87446ae64b8765b5'
                      }
                    ],
                    access: expected_file_access,
                    administrative: {
                      publish: true,
                      sdrPreserve: false,
                      shelve: true
                    }
                  },
                  {
                    type: 'https://cocina.sul.stanford.edu/models/file',
                    externalIdentifier: 'https://cocina.sul.stanford.edu/file/0d896cd1-57e3-4fc1-93c0-dd0e37d4e65a',
                    label: 'sanluisobispo1996-iso19110.xml',
                    filename: 'sanluisobispo1996-iso19110.xml',
                    size: 10664,
                    version: 1,
                    hasMimeType: 'application/xml',
                    use: 'derivative',
                    hasMessageDigests: [
                      {
                        type: 'sha1',
                        digest: '1876a5fc23a1bd3daf358b462adf0eef7875ba98'
                      },
                      {
                        type: 'md5',
                        digest: '74370eaaaa0f9bb8dc5999d2085700ac'
                      }
                    ],
                    access: expected_file_access,
                    administrative: {
                      publish: true,
                      sdrPreserve: false,
                      shelve: true
                    }
                  },
                  {
                    type: 'https://cocina.sul.stanford.edu/models/file',
                    externalIdentifier: 'https://cocina.sul.stanford.edu/file/0d896cd1-57e3-4fc1-93c0-dd0e37d4e65a',
                    label: 'sanluisobispo1996-fgdc.xml',
                    filename: 'sanluisobispo1996-fgdc.xml',
                    size: 7623,
                    version: 1,
                    hasMimeType: 'application/xml',
                    use: 'derivative',
                    hasMessageDigests: [
                      {
                        type: 'sha1',
                        digest: '30c5b696df09f9374179c68e41b1b86374238071'
                      },
                      {
                        type: 'md5',
                        digest: 'f88eeb259276b419a8c5f73a7fc8c1b3'
                      }
                    ],
                    access: expected_file_access,
                    administrative: {
                      publish: true,
                      sdrPreserve: false,
                      shelve: true
                    }
                  }
                ]
              }
            }
          ],
          hasMemberOrders: [],
          isMemberOf: [
            'druid:rz415nf2825'
          ]
        }
      end

      it 'creates structural' do
        test_perform(robot, druid)
        expect(object_client).to have_received(:update) do |args|
          expect(args[:params].structural.to_h).to match(expected_structural)
        end
      end

      context 'with citation-only view rights and no download on the containing cocina object' do # rubocop:disable RSpec/NestedGroups
        let(:cocina_object_access) do
          {
            view: 'citation-only',
            download: 'none',
            controlledDigitalLending: false
          }
        end

        let(:expected_file_access) do
          {
            view: 'dark',
            download: 'none',
            controlledDigitalLending: false
          }
        end

        it 'creates structural with the expected file rights' do
          test_perform(robot, druid)
          expect(object_client).to have_received(:update) do |args|
            expect(args[:params].structural.to_h).to match(expected_structural)
          end
        end
      end
    end

    context 'with raster data' do
      let(:druid) { 'druid:rc709sz0113' }
      let(:expected_file_access) do
        {
          view: 'world',
          download: 'world',
          controlledDigitalLending: false
        }
      end
      let(:expected_structural) do
        {
          contains: [
            {
              type: 'https://cocina.sul.stanford.edu/models/resources/object',
              externalIdentifier: 'rc709sz0113_1',
              label: 'Data',
              version: 1,
              structural: {
                contains: [
                  {
                    type: 'https://cocina.sul.stanford.edu/models/file',
                    externalIdentifier: 'https://cocina.sul.stanford.edu/file/8222376b-861f-4cb1-8ebb-c2ae6b112b4e',
                    label: 'SF_1973.tif',
                    filename: 'SF_1973.tif',
                    size: 31_565_174,
                    version: 1,
                    hasMimeType: 'image/tiff',
                    use: 'master',
                    hasMessageDigests: [
                      {
                        type: 'sha1',
                        digest: 'a1eef58b597dbd0f54ce4118c6872d62f9aa5c1d'
                      },
                      {
                        type: 'md5',
                        digest: '9d4b28017012fa9f39c31699ea49e80d'
                      }
                    ],
                    access: expected_file_access,
                    administrative: {
                      publish: true,
                      sdrPreserve: true,
                      shelve: true
                    }
                  },
                  {
                    type: 'https://cocina.sul.stanford.edu/models/file',
                    externalIdentifier: 'https://cocina.sul.stanford.edu/file/ec13ab89-39b0-455d-8b2c-f6e1c9cc8e60',
                    label: 'SF_1973.tif.ovr',
                    filename: 'SF_1973.tif.ovr',
                    size: 1733109,
                    version: 1,
                    hasMimeType: 'application/octet-stream',
                    use: 'master',
                    hasMessageDigests: [
                      {
                        type: 'sha1',
                        digest: 'ce3dddf4dd8be7bd4e3fe08cb41380e8b6282a98'
                      },
                      {
                        type: 'md5',
                        digest: '0bfb35fd073103e891c801649a0cbe85'
                      }
                    ],
                    access: {
                      view: 'world',
                      download: 'world',
                      controlledDigitalLending: false
                    },
                    administrative: {
                      publish: true,
                      sdrPreserve: true,
                      shelve: true
                    }
                  },
                  {
                    type: 'https://cocina.sul.stanford.edu/models/file',
                    externalIdentifier: 'https://cocina.sul.stanford.edu/file/0d896cd1-57e3-4fc1-93c0-dd0e37d4e65a',
                    label: 'SF_1973.tif.aux.xml',
                    filename: 'SF_1973.tif.aux.xml',
                    size: 2685,
                    version: 1,
                    hasMimeType: 'application/xml',
                    use: 'master',
                    hasMessageDigests: [
                      {
                        type: 'sha1',
                        digest: '970a9dac559726e7e73c44fcb68ad0a3d1b6e8ed'
                      },
                      {
                        type: 'md5',
                        digest: 'c2daddd099948c5f36b0abf62d1b03c1'
                      }
                    ],
                    access: {
                      view: 'world',
                      download: 'world',
                      controlledDigitalLending: false
                    },
                    administrative: {
                      publish: true,
                      sdrPreserve: true,
                      shelve: true
                    }
                  }
                ]
              }
            },
            {
              type: 'https://cocina.sul.stanford.edu/models/resources/preview',
              externalIdentifier: 'rc709sz0113_2',
              label: 'Preview',
              version: 1,
              structural: {
                contains: [
                  {
                    type: 'https://cocina.sul.stanford.edu/models/file',
                    externalIdentifier: 'https://cocina.sul.stanford.edu/file/0d896cd1-57e3-4fc1-93c0-dd0e37d4e65a',
                    label: 'preview.jpg',
                    filename: 'preview.jpg',
                    size: 4934,
                    version: 1,
                    hasMimeType: 'image/jpeg',
                    use: 'master',
                    hasMessageDigests: [
                      {
                        type: 'sha1',
                        digest: '026518fc315bf8a736c80b6c557e8644638b37bb'
                      },
                      {
                        type: 'md5',
                        digest: '2b401553a9e9d77a271a399b9155a944'
                      }
                    ],
                    access: expected_file_access,
                    administrative: {
                      publish: true,
                      sdrPreserve: true,
                      shelve: true
                    },
                    presentation: {
                      height: 128,
                      width: 117
                    }
                  }
                ]
              }
            },
            {
              type: 'https://cocina.sul.stanford.edu/models/resources/object',
              externalIdentifier: 'rc709sz0113_3',
              label: 'Metadata',
              version: 1,
              structural: {
                contains: [
                  {
                    type: 'https://cocina.sul.stanford.edu/models/file',
                    externalIdentifier: 'https://cocina.sul.stanford.edu/file/0d896cd1-57e3-4fc1-93c0-dd0e37d4e65a',
                    label: 'SF_1973.tif.xml',
                    filename: 'SF_1973.tif.xml',
                    size: 17389,
                    version: 1,
                    hasMimeType: 'application/xml',
                    use: 'master',
                    hasMessageDigests: [
                      {
                        type: 'sha1',
                        digest: 'a835134335da3d61a8bf96b719173f8ac9bc2cc8'
                      },
                      {
                        type: 'md5',
                        digest: 'bc08dfb78e69b200021c230096315d45'
                      }
                    ],
                    access: expected_file_access,
                    administrative: {
                      publish: true,
                      sdrPreserve: true,
                      shelve: true
                    }
                  },
                  {
                    type: 'https://cocina.sul.stanford.edu/models/file',
                    externalIdentifier: 'https://cocina.sul.stanford.edu/file/0d896cd1-57e3-4fc1-93c0-dd0e37d4e65a',
                    label: 'SF_1973-iso19139.xml',
                    filename: 'SF_1973-iso19139.xml',
                    size: 22729,
                    version: 1,
                    hasMimeType: 'application/xml',
                    use: 'derivative',
                    hasMessageDigests: [
                      {
                        type: 'sha1',
                        digest: '3e342a65c6207d17f0bfe93dd94802d414f2cbb1'
                      },
                      {
                        type: 'md5',
                        digest: '412a5972b7c140620d707e83123f86b5'
                      }
                    ],
                    access: expected_file_access,
                    administrative: {
                      publish: true,
                      sdrPreserve: false,
                      shelve: true
                    }
                  },
                  {
                    type: 'https://cocina.sul.stanford.edu/models/file',
                    externalIdentifier: 'https://cocina.sul.stanford.edu/file/0d896cd1-57e3-4fc1-93c0-dd0e37d4e65a',
                    label: 'SF_1973-fgdc.xml',
                    filename: 'SF_1973-fgdc.xml',
                    size: 5801,
                    version: 1,
                    hasMimeType: 'application/xml',
                    use: 'derivative',
                    hasMessageDigests: [
                      {
                        type: 'sha1',
                        digest: 'de5374c00f9cca56502582993bcfc83acc4b8d90'
                      },
                      {
                        type: 'md5',
                        digest: '103abf09c35484699bedcda45eb55edc'
                      }
                    ],
                    access: expected_file_access,
                    administrative: {
                      publish: true,
                      sdrPreserve: false,
                      shelve: true
                    }
                  }
                ]
              }
            }
          ],
          hasMemberOrders: [],
          isMemberOf: [
            'druid:rz415nf2825'
          ]
        }
      end

      it 'creates structural with the expected file rights' do
        test_perform(robot, druid)
        expect(object_client).to have_received(:update) do |args|
          expect(args[:params].structural.to_h).to match(expected_structural)
        end
      end
    end

    context 'with an index map file' do
      let(:druid) { 'druid:wf887zc4874' }

      let(:expected_file_access) do
        {
          view: 'world',
          download: 'world',
          controlledDigitalLending: false
        }
      end

      let(:expected_file) do
        {
          type: 'https://cocina.sul.stanford.edu/models/file',
          externalIdentifier: 'https://cocina.sul.stanford.edu/file/8222376b-861f-4cb1-8ebb-c2ae6b112b4e',
          label: 'index_map.json',
          filename: 'index_map.json',
          size: 13275,
          version: 1,
          hasMimeType: 'application/json',
          use: 'master',
          hasMessageDigests: [
            {
              type: 'sha1',
              digest: '71138d89033c0a7f4ac1c21664cf3228b8404648'
            },
            {
              type: 'md5',
              digest: '52378794a017c0a10d718c9b08987680'
            }
          ],
          access: expected_file_access,
          administrative: {
            publish: true,
            sdrPreserve: true,
            shelve: true
          }
        }
      end

      it 'creates structural' do
        test_perform(robot, druid)
        expect(object_client).to have_received(:update) do |args|
          structural = args[:params].structural
          expect(structural.contains.length).to eq(3)
          fileset = structural.contains.first
          expect(fileset.structural.contains.length).to eq(1)
          expect(fileset.structural.contains.last.to_h).to match(expected_file)
        end
      end

      context 'with citation-only view rights and no download on the containing cocina object' do # rubocop:disable RSpec/NestedGroups
        let(:cocina_object_access) do
          {
            view: 'citation-only',
            download: 'none',
            controlledDigitalLending: false
          }
        end

        let(:expected_file_access) do
          {
            view: 'dark',
            download: 'none',
            controlledDigitalLending: false
          }
        end

        it 'creates structural with the expected file rights' do
          test_perform(robot, druid)
          expect(object_client).to have_received(:update) do |args|
            structural = args[:params].structural
            expect(structural.contains.length).to eq(3)
            fileset = structural.contains.first
            expect(fileset.structural.contains.length).to eq(1)
            expect(fileset.structural.contains.last.to_h).to match(expected_file)
          end
        end
      end
    end
  end
end
