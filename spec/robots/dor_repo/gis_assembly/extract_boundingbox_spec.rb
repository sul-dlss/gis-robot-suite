# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::ExtractBoundingbox do
  let(:robot) { described_class.new }
  let(:cocina_object) { build(:dro, id: druid).new(description: original_description) }

  let(:druid) { 'druid:nj441df9572' }

  # rubocop:disable Layout/LineLength
  let(:original_description) do
    { title: [{ value: 'Afghanistan 2G Mobile Coverage Explorer, 2010' }],
      purl: 'https://purl.stanford.edu/nj441df9572',
      note: [{ value: 'This raster dataset is a representation of the coverage area for 2G mobile communications networks in Afghanistan. Mobile Coverage is released annually in January each year. This data release is named 2010. Any operator data received up to the end of the year 2009 is included in this release. The data is made available in GeoTIFF 2-BIT raster format with pre-built pyramids using nearest-neighbour resampling - with a nominal resolution of approximately 260 metres on the ground at the equator. Operators are asked to submit strong (indoor) and variable (outdoor) signal strengths: 2G (GSM) Greater than / -92 dBm -92 to -100 dBm, 3G (UMTS) Greater than -92 dBm / -92 to -100 dBm, 4G (LTE) Greater than -105 dBm / -105 to -120 dBm. However, the data received from operators often does not include signal strength information or does not follow the above guidelines. Therefore, whilst the rasters retain the strong and variable distinctions, this inconsistency must be understood by the user.The cell values in the MCE rasters are as follows: 1 - strong signal strength 2 - variable signal strength.',
               displayLabel: 'Abstract',
               valueLanguage: { code: 'eng', source: { code: 'iso639-2b' } } },
             { value: 'Operators are asked to submit strong (>= -92dBm) and variable (>= -100dBm and < 92dBm) signal strengths as part of their submissions. The data here includes both types but does not make a distinction between the two.',
               displayLabel: 'Supplemental information' }],
      language: [{ code: 'eng', source: { code: 'iso639-2b' } }],
      contributor: [{ name: [{ value: 'Collins Bartholomew Ltd.' }], type: 'organization', role: [{ source: { code: 'marcrelator' }, value: 'creator' }] }],
      event: [{ location: [{ value: 'Glasgow, GB' }],
                contributor: [{ name: [{ value: 'Collins Bartholomew Ltd.' }],
                                role: [{ value: 'publisher',
                                         code: 'pbl',
                                         uri: 'http://id.loc.gov/vocabulary/relators/pbl',
                                         source: { code: 'marcrelator', uri: 'http://id.loc.gov/vocabulary/relators/' } }],
                                type: 'organization' }],
                date: [{ value: '2010', encoding: { code: 'w3cdtf' }, status: 'primary', type: 'publication' }] }],
      subject: [{ source: { code: 'lcsh', uri: 'http://id.loc.gov/authorities/subjects.html' },
                  valueLanguage: { code: 'eng', source: { code: 'iso639-2b' } },
                  value: 'Wireless communication systems',
                  type: 'topic' },
                { valueLanguage: { code: 'eng', source: { code: 'iso639-2b' } }, value: 'Afghanistan', type: 'place' },
                { encoding: { code: 'w3cdtf' }, value: '2010', type: 'time' },
                { source: { code: 'ISO19115TopicCategory', uri: 'http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_TopicCategoryCode' },
                  uri: 'utilitiesCommunication',
                  value: 'Utilities and Communication',
                  type: 'topic' },
                { value: 'E 56°15ʹ--E 72°22ʹ7ʺ/N 38°9ʹ59ʺ--N 30°7ʹ12ʺ', type: 'map coordinates' }],
      form: [{ type: 'genre', value: 'Geospatial data', uri: 'http://id.loc.gov/authorities/genreForms/gf2011026297', source: { code: 'lcgft' } },
             { type: 'genre',
               value: 'cartographic dataset',
               uri: 'http://rdvocab.info/termList/RDAContentType/1001',
               source: { code: 'rdacontent' } },
             { value: 'cartographic', type: 'resource type', source: { value: 'MODS resource types' } },
             { value: 'software, multimedia', type: 'resource type', source: { value: 'MODS resource types' } },
             { value: 'GeoTIFF', type: 'form' },
             { value: '10.046', type: 'extent' },
             { value: 'born digital', type: 'digital origin', source: { value: 'MODS digital origin terms' } },
             { value: 'Scale not given.', type: 'map scale' },
             { value: 'Custom projection', type: 'map projection' }],
      adminMetadata: { language: [{ code: 'eng', source: { code: 'iso639-2b' } }],
                       contributor: [{ name: [{ value: 'Stanford' }] }],
                       note: [{ type: 'record origin', value: 'This record was translated from ISO 19139 to MODS v.3 using an xsl transformation.' }],
                       identifier: [{ value: 'edu.stanford.purl:nj441df9572' }] },
      geographic: [{ form: [{ value: 'image/tiff', type: 'media type', source: { value: 'IANA media type terms' } },
                            { value: 'GeoTIFF', type: 'data format' },
                            { value: 'Dataset#', type: 'type' }],
                     subject: [{ structuredValue: [{ value: '56.249996', type: 'west' },
                                                   { value: '30.119975', type: 'south' },
                                                   { value: '72.368695', type: 'east' },
                                                   { value: '38.16636', type: 'north' }],
                                 type: 'bounding box coordinates',
                                 encoding: { value: 'decimal' },
                                 standard: { code: 'EPSG:4326' } },
                               { value: 'Afghanistan', type: 'coverage', valueLanguage: { code: 'eng' } }] }] }
  end

  let(:expected_description) do
    {
      title: [
        {
          value: 'Afghanistan 2G Mobile Coverage Explorer, 2010'
        }
      ],
      contributor: [
        {
          name: [
            {
              value: 'Collins Bartholomew Ltd.'
            }
          ],
          type: 'organization',
          role: [
            {
              value: 'creator',
              source: {
                code: 'marcrelator'
              }
            }
          ]
        }
      ],
      event: [
        {
          date: [
            {
              value: '2010',
              type: 'publication',
              status: 'primary',
              encoding: {
                code: 'w3cdtf'
              }
            }
          ],
          contributor: [
            {
              name: [
                {
                  value: 'Collins Bartholomew Ltd.'
                }
              ],
              type: 'organization',
              role: [
                {
                  value: 'publisher',
                  code: 'pbl',
                  uri: 'http://id.loc.gov/vocabulary/relators/pbl',
                  source: {
                    code: 'marcrelator',
                    uri: 'http://id.loc.gov/vocabulary/relators/'
                  }
                }
              ]
            }
          ],
          location: [
            {
              value: 'Glasgow, GB'
            }
          ]
        }
      ],
      form: [
        {
          value: 'Geospatial data',
          type: 'genre',
          uri: 'http://id.loc.gov/authorities/genreForms/gf2011026297',
          source: {
            code: 'lcgft'
          }
        },
        {
          value: 'cartographic dataset',
          type: 'genre',
          uri: 'http://rdvocab.info/termList/RDAContentType/1001',
          source: {
            code: 'rdacontent'
          }
        },
        {
          value: 'cartographic',
          type: 'resource type',
          source: {
            value: 'MODS resource types'
          }
        },
        {
          value: 'software, multimedia',
          type: 'resource type',
          source: {
            value: 'MODS resource types'
          }
        },
        {
          value: 'GeoTIFF',
          type: 'form'
        },
        {
          value: '10.046',
          type: 'extent'
        },
        {
          value: 'born digital',
          type: 'digital origin',
          source: {
            value: 'MODS digital origin terms'
          }
        },
        {
          value: 'Scale not given.',
          type: 'map scale'
        },
        {
          value: 'Custom projection',
          type: 'map projection'
        },
        {
          value: 'EPSG::4326',
          type: 'map projection',
          uri: 'http://opengis.net/def/crs/EPSG/0/4326',
          source: {
            code: 'EPSG'
          },
          displayLabel: 'WGS84'
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
                  value: '56.2499964',
                  type: 'west'
                },
                {
                  value: '30.1199748',
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
              standard: {
                code: 'EPSG:4326'
              },
              encoding: {
                value: 'decimal'
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
      ],
      language: [
        {
          code: 'eng',
          source: {
            code: 'iso639-2b'
          }
        }
      ],
      note: [
        {
          value: 'This raster dataset is a representation of the coverage area for 2G mobile communications networks in Afghanistan. Mobile Coverage is released annually in January each year. This data release is named 2010. Any operator data received up to the end of the year 2009 is included in this release. The data is made available in GeoTIFF 2-BIT raster format with pre-built pyramids using nearest-neighbour resampling - with a nominal resolution of approximately 260 metres on the ground at the equator. Operators are asked to submit strong (indoor) and variable (outdoor) signal strengths: 2G (GSM) Greater than / -92 dBm -92 to -100 dBm, 3G (UMTS) Greater than -92 dBm / -92 to -100 dBm, 4G (LTE) Greater than -105 dBm / -105 to -120 dBm. However, the data received from operators often does not include signal strength information or does not follow the above guidelines. Therefore, whilst the rasters retain the strong and variable distinctions, this inconsistency must be understood by the user.The cell values in the MCE rasters are as follows: 1 - strong signal strength 2 - variable signal strength.',
          displayLabel: 'Abstract',
          valueLanguage: {
            code: 'eng',
            source: {
              code: 'iso639-2b'
            }
          }
        },
        {
          value: 'Operators are asked to submit strong (>= -92dBm) and variable (>= -100dBm and < 92dBm) signal strengths as part of their submissions. The data here includes both types but does not make a distinction between the two.',
          displayLabel: 'Supplemental information'
        },
        {
          value: 'This layer is presented in the WGS84 coordinate system for web display purposes. Downloadable data are provided in native coordinate system or projection.',
          displayLabel: 'WGS84 Cartographics'
        }
      ],
      subject: [
        {
          value: 'Wireless communication systems',
          type: 'topic',
          source: {
            code: 'lcsh',
            uri: 'http://id.loc.gov/authorities/subjects.html'
          },
          valueLanguage: {
            code: 'eng',
            source: {
              code: 'iso639-2b'
            }
          }
        },
        {
          value: 'Afghanistan',
          type: 'place',
          valueLanguage: {
            code: 'eng',
            source: {
              code: 'iso639-2b'
            }
          }
        },
        {
          value: '2010',
          type: 'time',
          encoding: {
            code: 'w3cdtf'
          }
        },
        {
          value: 'Utilities and Communication',
          type: 'topic',
          uri: 'utilitiesCommunication',
          source: {
            code: 'ISO19115TopicCategory',
            uri: 'http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_TopicCategoryCode'
          }
        },
        {
          value: 'E 56°15ʹ--E 72°22ʹ7ʺ/N 38°9ʹ59ʺ--N 30°7ʹ12ʺ',
          type: 'map coordinates'
        }
      ],
      adminMetadata: {
        contributor: [
          {
            name: [
              {
                value: 'Stanford'
              }
            ]
          }
        ],
        language: [
          {
            code: 'eng',
            source: {
              code: 'iso639-2b'
            }
          }
        ],
        note: [
          {
            value: 'This record was translated from ISO 19139 to MODS v.3 using an xsl transformation.',
            type: 'record origin'
          }
        ],
        identifier: [
          {
            value: 'edu.stanford.purl:nj441df9572'
          }
        ]
      },
      purl: 'https://purl.stanford.edu/nj441df9572'
    }
  end
  # rubocop:enable Layout/LineLength

  let(:object_client) { instance_double(Dor::Services::Client::Object, find: cocina_object, update: nil) }
  let(:file) do
    instance_double(File, readlines: [
                      "Upper Left  (56.2499964,  38.16636) (122d17' 4.70\"W, 35d58'37.30\"N)",
                      "Lower Right (72.368695, 30.1199748) (121d54'34.12\"W, 35d33'29.46\"N)"
                    ])
  end

  before do
    allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    allow(IO).to receive(:popen).and_yield(file)
  end

  it 'updates the cocina with the bounding box' do
    test_perform(robot, druid)
    expect(object_client).to have_received(:update) { |args| expect(args[:params].description.to_h).to match Cocina::Models::Description.new(expected_description).to_h }
  end
end
