# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::ExtractBoundingbox do
  let(:robot) { described_class.new }
  let(:cocina_object) { build(:dro, id: druid).new(description: original_description) }

  let(:druid) { 'druid:nj441df9572' }

  context 'when already EPSG 4326' do
    let(:original_description) do
      {
        title: [
          {
            value: 'Afghanistan 2G Mobile Coverage Explorer, 2010'
          }
        ],
        purl: 'https://purl.stanford.edu/nj441df9572',
        subject: [
          # {
          #   value: 'E 56°15ʹ--E 72°22ʹ7ʺ/N 38°9ʹ59ʺ--N 30°7ʹ12ʺ',
          #   type: 'map coordinates'
          # }
        ],
        form: [
          {
            value: 'GeoTIFF',
            type: 'form'
          },
          # {
          #   value: 'Scale not given.',
          #   type: 'map scale'
          # },
          # {
          #   value: 'Custom projection',
          #   type: 'map projection'
          # },
          {
            value: 'EPSG::4326',
            type: 'map projection'
            # uri: 'http://opengis.net/def/crs/EPSG/0/4326',
            # source: {
            #   code: 'EPSG'
            # },
            # displayLabel: 'WGS84'
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
              }
            ]
          }
        ]
      }
    end

    let(:expected_description) do
      {
        title: [
          {
            value: 'Afghanistan 2G Mobile Coverage Explorer, 2010'
          }
        ],
        form: [
          {
            value: 'GeoTIFF',
            type: 'form'
          },
          # {
          #   value: 'Scale not given.',
          #   type: 'map scale'
          # },
          # {
          #   value: 'Custom projection',
          #   type: 'map projection'
          # },
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
              }
            ]
          }
        ],
        note: [
          # {
          #   value: 'This layer is presented in the WGS84 coordinate system for web display purposes. Downloadable data are provided in native coordinate system or projection.',
          #   displayLabel: 'WGS84 Cartographics'
          # }
        ],
        subject: [
          # {
          #   value: 'E 56°15ʹ--E 72°22ʹ7ʺ/N 38°9ʹ59ʺ--N 30°7ʹ12ʺ',
          #   type: 'map coordinates'
          # }
        ],
        purl: 'https://purl.stanford.edu/nj441df9572'
      }
    end
    let(:object_client) { instance_double(Dor::Services::Client::Object, find: cocina_object, update: nil) }

    before do
      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
      allow(IO).to receive(:popen).and_call_original
    end

    it 'updates the cocina with the bounding box' do
      test_perform(robot, druid)
      expect(object_client).to have_received(:update) { |args| expect(args[:params].description.to_h).to match Cocina::Models::Description.new(expected_description).to_h }
      expect(IO).to have_received(:popen).with("gdalinfo '/tmp/extractboundingbox_nj441df9572/MCE_AF2G_2010.tif'")
    end
  end

  context 'when not already EPSG 4326' do
    let(:original_description) do
      { title: [{ value: 'Afghanistan 2G Mobile Coverage Explorer, 2010' }],
        purl: 'https://purl.stanford.edu/nj441df9572',
        subject: [
          {
            value: 'E 56°15ʹ--E 72°22ʹ7ʺ/N 38°9ʹ59ʺ--N 30°7ʹ12ʺ',
            type: 'map coordinates'
          }
        ],
        form: [
          {
            value: 'GeoTIFF',
            type: 'form'
          },
          # {
          #   value: 'Scale not given.',
          #   type: 'map scale'
          # },
          {
            value: 'Custom projection',
            type: 'map projection'
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
              # Note that this is not EPSG:4326
              {
                structuredValue: [
                  {
                    value: '156.249996',
                    type: 'west'
                  },
                  {
                    value: '130.119975',
                    type: 'south'
                  },
                  {
                    value: '172.368695',
                    type: 'east'
                  },
                  {
                    value: '138.16636',
                    type: 'north'
                  }
                ],
                type: 'bounding box coordinates',
                encoding: {
                  value: 'decimal'
                },
                standard: {
                  code: 'EPSG:4327'
                }
              }
            ]
          }
        ] }
    end

    let(:expected_description) do
      {
        title: [
          {
            value: 'Afghanistan 2G Mobile Coverage Explorer, 2010'
          }
        ],
        form: [
          {
            value: 'GeoTIFF',
            type: 'form'
          },
          {
            value: 'Custom projection',
            type: 'map projection'
          },
          {
            value: 'Scale not given.',
            type: 'map scale'
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
              }
            ]
          }
        ],
        note: [
          {
            value: 'This layer is presented in the WGS84 coordinate system for web display purposes. Downloadable data are provided in native coordinate system or projection.',
            displayLabel: 'WGS84 Cartographics'
          }
        ],
        subject: [
          {
            value: 'E 56°15ʹ--E 72°22ʹ7ʺ/N 38°9ʹ59ʺ--N 30°7ʹ12ʺ',
            type: 'map coordinates'
          }
        ],
        purl: 'https://purl.stanford.edu/nj441df9572'
      }
    end
    let(:object_client) { instance_double(Dor::Services::Client::Object, find: cocina_object, update: nil) }

    before do
      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
      allow(IO).to receive(:popen).and_call_original
    end

    it 'updates the cocina with the bounding box' do
      test_perform(robot, druid)
      expect(object_client).to have_received(:update) { |args| expect(args[:params].description.to_h).to match Cocina::Models::Description.new(expected_description).to_h }
      expect(IO).to have_received(:popen).with("gdalinfo '/tmp/extractboundingbox_nj441df9572/MCE_AF2G_2010.tif'")
    end
  end
end
