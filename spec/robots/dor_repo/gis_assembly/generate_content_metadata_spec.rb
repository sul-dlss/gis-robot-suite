# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::GenerateContentMetadata do
  describe '#perform_work' do
    let(:robot) { described_class.new }
    let(:cocina_model) do
      build(:dro, id: druid).new(
        structural: {
          contains: [],
          hasMemberOrders: [],
          isMemberOf: ['druid:rz415nf2825']
        },
        access: {
          view: 'world',
          download: 'world',
          controlledDigitalLending: false
        }
      )
    end

    let(:object_client) do
      instance_double(Dor::Services::Client::Object, find: cocina_model, update: true)
    end

    before do
      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
      allow(SecureRandom).to receive(:uuid).and_return('8222376b-861f-4cb1-8ebb-c2ae6b112b4e', 'ec13ab89-39b0-455d-8b2c-f6e1c9cc8e60', '0d896cd1-57e3-4fc1-93c0-dd0e37d4e65a',
                                                       'd665cf1c-9914-45bc-82e7-bbf946a614d8')
    end

    context 'without an index map file' do
      let(:druid) { 'druid:cc044gt0726' }
      let(:bare_druid) { druid.delete_prefix('druid:') }

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
                    label: "#{bare_druid}.zip",
                    filename: "#{bare_druid}.zip",
                    size: 1763115,
                    version: 1,
                    hasMimeType: 'application/zip',
                    use: 'master',
                    hasMessageDigests: [
                      {
                        type: 'sha1',
                        digest: 'eaed4019f2d012ff1e0b795b3ff8795e19cf3d7a'
                      },
                      {
                        type: 'md5',
                        digest: '86b7905d67d84e5750c2e7f3aa473ba9'
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
                    externalIdentifier: 'https://cocina.sul.stanford.edu/file/ec13ab89-39b0-455d-8b2c-f6e1c9cc8e60',
                    label: "#{bare_druid}_normalized.zip",
                    filename: "#{bare_druid}_normalized.zip",
                    size: 2031104,
                    version: 1,
                    hasMimeType: 'application/zip',
                    use: 'derivative',
                    hasMessageDigests: [
                      {
                        type: 'sha1',
                        digest: '4786e61d6230370dfa2841fde3876a49e7e90dcc'
                      },
                      {
                        type: 'md5',
                        digest: 'e0cc2902a0265e12ab688c396f29b546'
                      }
                    ],
                    access: {
                      view: 'world',
                      download: 'world',
                      controlledDigitalLending: false
                    },
                    administrative: {
                      publish: true,
                      sdrPreserve: false,
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
                    access: {
                      view: 'world',
                      download: 'world',
                      controlledDigitalLending: false
                    },
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
    end

    context 'with an index map file' do
      let(:druid) { 'druid:wf887zc4874' }

      let(:expected_file) do
        {
          type: 'https://cocina.sul.stanford.edu/models/file',
          externalIdentifier: 'https://cocina.sul.stanford.edu/file/0d896cd1-57e3-4fc1-93c0-dd0e37d4e65a',
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
      end

      it 'creates structural' do
        test_perform(robot, druid)
        expect(object_client).to have_received(:update) do |args|
          structural = args[:params].structural
          expect(structural.contains.length).to eq(2)
          fileset = structural.contains.first
          expect(fileset.structural.contains.length).to eq(3)
          expect(fileset.structural.contains.last.to_h).to match(expected_file)
        end
      end
    end
  end
end
