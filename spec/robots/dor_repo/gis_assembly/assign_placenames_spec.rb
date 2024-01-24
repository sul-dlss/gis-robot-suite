# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::AssignPlacenames do
  let(:robot) { described_class.new }
  let(:cocina_object) { build(:dro, id: druid).new(description: original_description) }

  let(:druid) { 'druid:nj441df9572' }

  let(:original_description) do
    { title: [{ value: 'Afghanistan 2G Mobile Coverage Explorer, 2010' }],
      purl: 'https://purl.stanford.edu/nj441df9572',
      subject: [
        {
          source: {
            code: 'lcsh',
            uri: 'http://id.loc.gov/authorities/subjects.html'
          },
          valueLanguage: {
            code: 'eng',
            source: {
              code: 'iso639-2b'
            }
          },
          value: 'Wireless communication systems',
          type: 'topic'
        },
        {
          valueLanguage: {
            code: 'eng',
            source: {
              code: 'iso639-2b'
            }
          },
          value: 'Afghanistan',
          type: 'place'
        },
        # This place isn't found in gazetteer.
        {
          valueLanguage: {
            code: 'eng',
            source: {
              code: 'iso639-2b'
            }
          },
          value: 'xAfghanistan',
          type: 'place'
        },
        {
          encoding: {
            code: 'w3cdtf'
          },
          value: '2010',
          type: 'time'
        },
        {
          source: {
            code: 'ISO19115TopicCategory',
            uri: 'http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_TopicCategoryCode'
          },
          uri: 'utilitiesCommunication',
          value: 'Utilities and Communication',
          type: 'topic'
        },
        {
          value: 'E 56°15ʹ--E 72°22ʹ7ʺ/N 38°9ʹ59ʺ--N 30°7ʹ12ʺ',
          type: 'map coordinates'
        }
      ],
      geographic: [
        {
          form: [
            {
              value: 'image/tiff',
              type: 'media type',
              source: {
                value: 'IANA media type terms'
              }
            },
            {
              value: 'GeoTIFF',
              type: 'data format'
            },
            {
              value: 'Dataset#',
              type: 'type'
            }
          ],
          subject: [
            {
              structuredValue: [
                {
                  value: '56.249996',
                  type: 'west'
                },
                {
                  value: '30.119975',
                  type: 'south'
                },
                {
                  value: '72.368695',
                  type: 'east'
                },
                {
                  value: '38.16636',
                  type: 'north'
                }
              ],
              type: 'bounding box coordinates',
              encoding: {
                value: 'decimal'
              },
              standard: {
                code: 'EPSG:4326'
              }
            },
            {
              value: 'Afghanistan',
              type: 'coverage',
              valueLanguage: {
                code: 'eng'
              }
            }
          ]
        }
      ] }
  end

  let(:expected_description) do
    { title: [{ value: 'Afghanistan 2G Mobile Coverage Explorer, 2010' }],
      purl: 'https://purl.stanford.edu/nj441df9572',
      subject: [
        {
          source: {
            code: 'lcsh',
            uri: 'http://id.loc.gov/authorities/subjects.html'
          },
          valueLanguage: {
            code: 'eng',
            source: {
              code: 'iso639-2b'
            }
          },
          value: 'Wireless communication systems',
          type: 'topic'
        },
        {
          valueLanguage: {
            code: 'eng',
            source: {
              code: 'iso639-2b'
            }
          },
          value: 'Afghanistan',
          type: 'place',
          uri: 'http://sws.geonames.org/1149361/',
          source: {
            code: 'geonames',
            uri: 'http://www.geonames.org/ontology#'
          }
        },
        # This place isn't found in gazetteer.
        {
          valueLanguage: {
            code: 'eng',
            source: {
              code: 'iso639-2b'
            }
          },
          value: 'xAfghanistan',
          type: 'place'
        },
        {
          encoding: {
            code: 'w3cdtf'
          },
          value: '2010',
          type: 'time'
        },
        {
          source: {
            code: 'ISO19115TopicCategory',
            uri: 'http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_TopicCategoryCode'
          },
          uri: 'utilitiesCommunication',
          value: 'Utilities and Communication',
          type: 'topic'
        },
        {
          value: 'E 56°15ʹ--E 72°22ʹ7ʺ/N 38°9ʹ59ʺ--N 30°7ʹ12ʺ',
          type: 'map coordinates'
        }
      ],
      geographic: [
        {
          form: [
            {
              value: 'image/tiff',
              type: 'media type',
              source: {
                value: 'IANA media type terms'
              }
            },
            {
              value: 'GeoTIFF',
              type: 'data format'
            },
            {
              value: 'Dataset#',
              type: 'type'
            }
          ],
          subject: [
            {
              structuredValue: [
                {
                  value: '56.249996',
                  type: 'west'
                },
                {
                  value: '30.119975',
                  type: 'south'
                },
                {
                  value: '72.368695',
                  type: 'east'
                },
                {
                  value: '38.16636',
                  type: 'north'
                }
              ],
              type: 'bounding box coordinates',
              encoding: {
                value: 'decimal'
              },
              standard: {
                code: 'EPSG:4326'
              }
            },
            {
              value: 'Afghanistan',
              type: 'coverage',
              uri: 'http://sws.geonames.org/1149361/',
              valueLanguage: {
                code: 'eng'
              }
            }
          ]
        }
      ] }
  end
  let(:object_client) { instance_double(Dor::Services::Client::Object, find: cocina_object, update: nil) }

  before do
    allow(Dor::Services::Client).to receive(:object).and_return(object_client)
  end

  it 'updates the cocina with the assigned placenames' do
    test_perform(robot, druid)
    expect(object_client).to have_received(:update) { |args| expect(args[:params].description.to_h).to match Cocina::Models::Description.new(expected_description).to_h }
  end
end
