# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::ExtractBoundingbox do
  let(:robot) { described_class.new }
  let(:cocina_object) { build(:dro, id: druid).new(description: original_description) }

  let(:object_client) { instance_double(Dor::Services::Client::Object, find: cocina_object, update: nil) }

  let(:wkt) do
    'GEOGCS["WGS 84", DATUM["WGS_1984", SPHEROID["WGS 84",6378137,298.257223563, AUTHORITY["EPSG","7030"]], AUTHORITY["EPSG","6326"]], PRIMEM["Greenwich",0, AUTHORITY["EPSG","8901"]], UNIT["degree",0.0174532925199433, AUTHORITY["EPSG","9122"]], AUTHORITY["EPSG","4326"]]' # rubocop:disable Layout/LineLength
  end

  before do
    allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    allow(GisRobotSuite).to receive(:run_system_command).and_call_original
    stub_request(:get, 'https://spatialreference.org/ref/epsg/4326/prettywkt/')
      .to_return(status: 200, body: wkt, headers: {})
  end

  context 'when raster' do
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
          subject: [],
          form: [
            {
              value: 'GeoTIFF',
              type: 'form'
            },
            {
              value: 'EPSG::4326',
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
            {
              value: 'EPSG::4326',
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
                {
                  value: 'Afghanistan',
                  type: 'coverage',
                  uri: 'http://sws.geonames.org/1149361/',
                  valueLanguage: {
                    code: 'eng'
                  }
                },
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
          subject: [
            # {
            #   value: 'E 56°15ʹ--E 72°22ʹ7ʺ/N 38°9ʹ59ʺ--N 30°7ʹ12ʺ',
            #   type: 'map coordinates'
            # }
          ],
          purl: 'https://purl.stanford.edu/nj441df9572'
        }
      end

      it 'updates the cocina with the bounding box' do
        test_perform(robot, druid)
        expect(object_client).to have_received(:update) { |args| expect(args[:params].description.to_h).to match Cocina::Models::Description.new(expected_description).to_h }
        expect(GisRobotSuite).to have_received(:run_system_command).with("gdalinfo -json '/tmp/normalizeraster_nj441df9572/MCE_AF2G_2010.tif'", logger: robot.logger)
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
              subject: []
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
          subject: [
            {
              value: 'E 56°15ʹ--E 72°22ʹ7ʺ/N 38°9ʹ59ʺ--N 30°7ʹ12ʺ',
              type: 'map coordinates'
            }
          ],
          purl: 'https://purl.stanford.edu/nj441df9572'
        }
      end

      it 'updates the cocina with the bounding box' do
        test_perform(robot, druid)
        expect(object_client).to have_received(:update) { |args| expect(args[:params].description.to_h).to match Cocina::Models::Description.new(expected_description).to_h }
        expect(GisRobotSuite).to have_received(:run_system_command).with("gdalinfo -json '/tmp/normalizeraster_nj441df9572/MCE_AF2G_2010.tif'", logger: robot.logger)
      end
    end

    context 'when a previous bounding box exists' do
      let(:original_description) do
        {
          title: [
            {
              value: 'Afghanistan 2G Mobile Coverage Explorer, 2010'
            }
          ],
          purl: 'https://purl.stanford.edu/nj441df9572',
          subject: [],
          form: [
            {
              value: 'GeoTIFF',
              type: 'form'
            },
            {
              value: 'EPSG::4326',
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
                {
                  structuredValue: [
                    {
                      value: '50',
                      type: 'west'
                    },
                    {
                      value: '10',
                      type: 'south'
                    },
                    {
                      value: '40',
                      type: 'east'
                    },
                    {
                      value: '20',
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
            {
              value: 'EPSG::4326',
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
          note: [],
          subject: [
            # {
            #   value: 'E 56°15ʹ--E 72°22ʹ7ʺ/N 38°9ʹ59ʺ--N 30°7ʹ12ʺ',
            #   type: 'map coordinates'
            # }
          ],
          purl: 'https://purl.stanford.edu/nj441df9572'
        }
      end

      it 'updates the cocina with the new bounding box' do
        test_perform(robot, druid)
        expect(object_client).to have_received(:update) { |args| expect(args[:params].description.to_h).to match Cocina::Models::Description.new(expected_description).to_h }
        expect(GisRobotSuite).to have_received(:run_system_command).with("gdalinfo -json '/tmp/normalizeraster_nj441df9572/MCE_AF2G_2010.tif'", logger: robot.logger)
      end
    end
  end

  context 'when shapefile' do
    let(:druid) { 'druid:cc044gt0726' }
    let(:bounding_box) do
      # ogr2ogr produces slightly different bounding boxes depending on the version.
      # CI and production have an older version; brew installs a newer version.
      # Following accounts for this, but might break as versions change.
      if ci?
        [
          {
            value: '-121.347916',
            type: 'west'
          },
          {
            value: '34.897518',
            type: 'south'
          },
          {
            value: '-119.47262',
            type: 'east'
          },
          {
            value: '35.795222',
            type: 'north'
          }
        ]
      else
        [
          {
            value: '-121.347916',
            type: 'west'
          },
          {
            value: '34.897517',
            type: 'south'
          },
          {
            value: '-119.472622',
            type: 'east'
          },
          {
            value: '35.795226',
            type: 'north'
          }
        ]
      end
    end
    let(:expected_description) do
      {
        title: [
          {
            value: 'Important Farmland, San Luis Obispo County, California, 1996'
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
            value: 'Shapefile',
            type: 'form'
          },
          {
            value: '2.815',
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
            value: 'Custom projection',
            type: 'map projection'
          }
        ],
        geographic: [
          {
            form: [
              {
                value: 'application/x-esri-shapefile',
                type: 'media type',
                source: {
                  value: 'IANA media type terms'
                }
              },
              {
                value: 'Shapefile',
                type: 'data format'
              },
              {
                value: 'Dataset#Polygon',
                type: 'type'
              }
            ],
            subject: [
              {
                value: 'San Luis Obispo County (Calif.)',
                type: 'coverage',
                valueLanguage: {
                  code: 'eng'
                }
              },
              {
                structuredValue: bounding_box,
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
        purl: 'https://purl.stanford.edu/cc044gt0726'
      }
    end
    let(:original_description) do
      {
        title: [
          {
            value: 'Important Farmland, San Luis Obispo County, California, 1996'
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
            value: 'Shapefile',
            type: 'form'
          },
          {
            value: '2.815',
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
            value: 'Custom projection',
            type: 'map projection'
          }
        ],
        geographic: [
          {
            form: [
              {
                value: 'application/x-esri-shapefile',
                type: 'media type',
                source: {
                  value: 'IANA media type terms'
                }
              },
              {
                value: 'Shapefile',
                type: 'data format'
              },
              {
                value: 'Dataset#Polygon',
                type: 'type'
              }
            ],
            subject: [
              {
                value: 'San Luis Obispo County (Calif.)',
                type: 'coverage',
                valueLanguage: {
                  code: 'eng'
                }
              }
            ]
          }
        ],
        purl: 'https://purl.stanford.edu/cc044gt0726'
      }
    end

    def ci?
      cmd_result = GisRobotSuite.run_system_command("#{Settings.gdal_path}ogr2ogr --version", logger: Logger.new($stdout)) # provide a throw away logger
      cmd_result[:stdout_str].include?('GDAL 3.4')
    end

    it 'updates the cocina with the bounding box' do
      test_perform(robot, druid)
      expect(object_client).to have_received(:update) { |args| expect(args[:params].description.to_h).to match Cocina::Models::Description.new(expected_description).to_h }
      expect(GisRobotSuite).to have_received(:run_system_command).with("ogrinfo -ro -so -al '/tmp/normalizevector_cc044gt0726/sanluisobispo1996.shp'", logger: robot.logger)
    end
  end
end
