# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisDelivery::LoadGeoserver do
  let(:robot) { described_class.new }
  let(:workflow_client) { instance_double(Dor::Workflow::Client) }
  let(:object_client) { instance_double(Dor::Services::Client::Object, find: cocina_object) }
  let(:cocina_object) do
    dro = build(:dro, id: "druid:#{druid}")
    dro.new(
      description:,
      access: { view: 'world', download: 'world' }
    )
  end

  before do
    allow(LyberCore::WorkflowClientFactory).to receive(:build).and_return(workflow_client)
    allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    stub_request(:get, 'http://example.com/geoserver/rest/workspaces/druid')
      .to_return(status: 200, body: read_fixture('geoserver_responses/workspaces.json'), headers: {})
  end

  describe '#perform_work' do
    describe 'loading a vector dataset' do
      let(:druid) { 'bb338jh0716' }

      # rubocop:disable Layout/LineLength
      let(:description) do
        {
          title: [
            {
              value: 'Hydrologic Sub-Area Boundaries: Russian River Watershed, California, 1999'
            }
          ],
          contributor: [
            {
              name: [
                {
                  value: 'Circuit Rider Productions'
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
                  value: '2002',
                  type: 'publication',
                  status: 'primary',
                  encoding: {
                    code: 'w3cdtf'
                  }
                },
                {
                  value: '1999',
                  type: 'validity',
                  encoding: {
                    code: 'w3cdtf'
                  }
                }
              ],
              contributor: [
                {
                  name: [
                    {
                      value: 'Circuit Rider Productions'
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
                  value: 'Windsor, California, US'
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
              value: 'Shapefile',
              type: 'form'
            },
            {
              value: '0.3',
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
              value: 'EPSG::26910',
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
                  structuredValue: [
                    {
                      value: '-123.387626',
                      type: 'west'
                    },
                    {
                      value: '38.298673',
                      type: 'south'
                    },
                    {
                      value: '-122.528843',
                      type: 'east'
                    },
                    {
                      value: '39.399103',
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
              value: 'This polygon dataset represents the Hydrologic Sub-Area boundaries for the Russian River basin, as defined by the Calwater 2.2a watershed boundaries. The original CALWATER22 layer (Calwater 2.2a watershed boundaries) was developed as a coverage named calw22a and is administered by the Interagency California Watershed Mapping Committee (ICWMC).',
              displayLabel: 'Abstract',
              valueLanguage: {
                code: 'eng',
                source: {
                  code: 'iso639-2b'
                }
              }
            },
            {
              value: 'This shapefile can be used to map and analyze data at the Hydrologic Sub-Area scale.',
              type: 'abstract',
              displayLabel: 'Purpose',
              valueLanguage: {
                code: 'eng',
                source: {
                  code: 'iso639-2b'
                }
              }
            }
          ],
          subject: [
            {
              value: 'Hydrology',
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
              value: 'Watersheds',
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
              value: 'Sonoma County (Calif.)',
              type: 'place',
              uri: 'http://sws.geonames.org/5397100/',
              source: {
                code: 'geonames',
                uri: 'http://www.geonames.org/ontology#'
              },
              valueLanguage: {
                code: 'eng',
                source: {
                  code: 'iso639-2b'
                }
              }
            },
            {
              value: 'Mendocino County (Calif.)',
              type: 'place',
              uri: 'http://sws.geonames.org/5372163/',
              source: {
                code: 'geonames',
                uri: 'http://www.geonames.org/ontology#'
              },
              valueLanguage: {
                code: 'eng',
                source: {
                  code: 'iso639-2b'
                }
              }
            },
            {
              value: 'Russian River Watershed (Calif.)',
              type: 'place',
              valueLanguage: {
                code: 'eng',
                source: {
                  code: 'iso639-2b'
                }
              }
            },
            {
              value: '1999',
              type: 'time',
              encoding: {
                code: 'w3cdtf'
              }
            },
            {
              value: 'Boundaries',
              type: 'topic',
              uri: 'boundaries',
              source: {
                code: 'ISO19115TopicCategory',
                uri: 'http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_TopicCategoryCode'
              }
            },
            {
              value: 'Inland Waters',
              type: 'topic',
              uri: 'inlandWaters',
              source: {
                code: 'ISO19115TopicCategory',
                uri: 'http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_TopicCategoryCode'
              }
            },
            {
              value: 'W 123°23ʹ16ʺ--W 122°31ʹ22ʺ/N 39°23ʹ57ʺ--N 38°17ʹ53ʺ',
              type: 'map coordinates'
            },
            {
              value: 'W 123°23ʹ15ʺ--W 122°31ʹ44ʺ/N 39°23ʹ57ʺ--N 38°17ʹ55ʺ',
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
                value: 'edu.stanford.purl:bb338jh0716'
              }
            ]
          },
          purl: "https://purl.stanford.edu/#{druid}"
        }
      end
      # rubocop:enable Layout/LineLength

      let(:post_body) do
        '{"featureType":{"name":"bb338jh0716","title":"Hydrologic Sub-Area Boundaries: Russian River Watershed, California, 1999","enabled":true,"abstract":"This polygon dataset represents the Hydrologic Sub-Area boundaries for the Russian River basin, as defined by the Calwater 2.2a watershed boundaries. The original CALWATER22 layer (Calwater 2.2a watershed boundaries) was developed as a coverage named calw22a and is administered by the Interagency California Watershed Mapping Committee (ICWMC).\\nThis shapefile can be used to map and analyze data at the Hydrologic Sub-Area scale.","keywords":{"string":["Hydrology","Watersheds","Boundaries","Inland Waters","Sonoma County (Calif.)","Mendocino County (Calif.)","Russian River Watershed (Calif.)"]},"metadata_links":[],"metadata":{"cacheAgeMax":86400,"cachingEnabled":true}}}' # rubocop:disable Layout/LineLength
      end
      let(:media_type) { 'application/x-esri-shapefile' }

      before do
        stub_request(:get, 'http://example.com/geoserver/rest/workspaces/druid/datastores/postgis_druid')
          .to_return(status: 200, body: read_fixture('geoserver_responses/postgis_druid.json'), headers: {})
      end

      it 'runs without error' do
        stub_request(:get, 'http://example.com/geoserver/rest/workspaces/druid/datastores/postgis_druid/featuretypes/bb338jh0716')
          .to_return(status: 404)
        stubbed_post = stub_request(:post, 'http://example.com/geoserver/rest/workspaces/druid/datastores/postgis_druid/featuretypes')
                       .with(headers: { 'Content-Type' => 'application/json' }, body: post_body)
                       .to_return(status: 201)
        test_perform(robot, druid)
        expect(stubbed_post).to have_been_requested
      end

      it 'already existing, runs without error' do
        stub_request(:get, 'http://example.com/geoserver/rest/workspaces/druid/datastores/postgis_druid/featuretypes/bb338jh0716')
          .to_return(status: 200, body: {}.to_json)
        stubbed_post = stub_request(:put, 'http://example.com/geoserver/rest/workspaces/druid/datastores/postgis_druid/featuretypes/bb338jh0716')
                       .with(headers: { 'Content-Type' => 'application/json' }, body: post_body)
                       .to_return(status: 201)
        test_perform(robot, druid)
        expect(stubbed_post).to have_been_requested
      end
    end

    describe 'loading a raster dataset' do
      let(:druid) { 'dg548ft1892' }

      # rubocop:disable Layout/LineLength
      let(:description) do
        {
          title: [
            {
              value: '1000 Meter Resolution Bathymetry Grid of Exclusive Economic Zone (EEZ): Russian River Basin, California, 1998'
            }
          ],
          contributor: [
            {
              name: [
                {
                  value: 'Circuit Rider Productions'
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
                  value: '2002',
                  type: 'publication',
                  status: 'primary',
                  encoding: {
                    code: 'w3cdtf'
                  }
                },
                {
                  structuredValue: [
                    {
                      value: '1999',
                      type: 'start'
                    },
                    {
                      value: '2002',
                      type: 'end'
                    }
                  ],
                  type: 'validity',
                  encoding: {
                    code: 'w3cdtf'
                  }
                }
              ],
              contributor: [
                {
                  name: [
                    {
                      value: 'Circuit Rider Productions'
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
                  value: 'Windsor, California, US'
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
              value: 'Raster Dataset',
              type: 'form'
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
              value: 'EPSG::26910',
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
                  value: 'Dataset#Raster',
                  type: 'type'
                }
              ],
              subject: [
                {
                  structuredValue: [
                    {
                      value: '-134.3282944',
                      type: 'west'
                    },
                    {
                      value: '-6.0466073',
                      type: 'south'
                    },
                    {
                      value: '-124.8979013',
                      type: 'east'
                    },
                    {
                      value: '4.5480319',
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
              value: "Eez1000 is a 1000 meter resolution statewide bathymetric dataset that generally covers the Exclusive Economic Zone (EEZ), an area extending 200 nautical miles from all United States possessions and trust territories. The data was adapted from isobath values ranging from 200 meters to 4800 meters below sea level; therefore nearshore depictions ARE NOT ACCURATE and \"flatten out\" between 200 meter depths and the coastline. The data is intended only for general portrayals of offshore features and depths. The Department of Fish and Game (DFG), Technical Services Branch (TSB) GIS Unit received the source data in the form of a line contour coverage (known as DFG's eezbath) from the United States Geological Survey (USGS). The contour data was converted to a TIN (triangulated irregular network) using ArcView 3D Analyst and then converted to a grid. The contour data was previously reprojected by TSB to Albers conic equal-area using standard Teale Data Center parameters. Some minor aesthetic editing was performed on peripheral areas using the ARC/INFO Grid EXPAND function. The image version was created using the ARC/INFO GRIDIMAGE function. Please see the attached metadata file \"eezbatcall.doc\" or the DFG coverage metadata \"eezbath.txt\" for further source data information.",
              displayLabel: 'Abstract',
              valueLanguage: {
                code: 'eng',
                source: {
                  code: 'iso639-2b'
                }
              }
            },
            {
              value: 'This layer can be used for watershed analysis and planning in the Russian River region of California.',
              type: 'abstract',
              displayLabel: 'Purpose',
              valueLanguage: {
                code: 'eng',
                source: {
                  code: 'iso639-2b'
                }
              }
            }
          ],
          subject: [
            {
              value: 'Hydrography',
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
              value: 'Watersheds',
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
              value: 'Sonoma County (Calif.)',
              type: 'place',
              uri: 'http://sws.geonames.org/5397100/',
              source: {
                code: 'geonames',
                uri: 'http://www.geonames.org/ontology#'
              },
              valueLanguage: {
                code: 'eng',
                source: {
                  code: 'iso639-2b'
                }
              }
            },
            {
              value: 'Mendocino County (Calif.)',
              type: 'place',
              uri: 'http://sws.geonames.org/5372163/',
              source: {
                code: 'geonames',
                uri: 'http://www.geonames.org/ontology#'
              },
              valueLanguage: {
                code: 'eng',
                source: {
                  code: 'iso639-2b'
                }
              }
            },
            {
              value: 'Russian River Watershed (Calif.)',
              type: 'place',
              valueLanguage: {
                code: 'eng',
                source: {
                  code: 'iso639-2b'
                }
              }
            },
            {
              structuredValue: [
                {
                  value: '1999',
                  type: 'start'
                },
                {
                  value: '2002',
                  type: 'end'
                }
              ],
              type: 'time',
              encoding: {
                code: 'w3cdtf'
              }
            },
            {
              value: 'Inland Waters',
              type: 'topic',
              uri: 'inlandWaters',
              source: {
                code: 'ISO19115TopicCategory',
                uri: 'http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_TopicCategoryCode'
              }
            },
            {
              value: 'W 134°19ʹ42ʺ--W 124°53ʹ44ʺ/N 4°32ʹ53ʺ--S 6°2ʹ57ʺ',
              type: 'map coordinates'
            },
            {
              value: 'W 134°19ʹ42ʺ--W 124°53ʹ52ʺ/N 4°32ʹ53ʺ--S 6°2ʹ48ʺ',
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
                value: 'edu.stanford.purl:dg548ft1892'
              }
            ]
          },
          purl: "https://purl.stanford.edu/#{druid}"
        }
      end
      # rubocop:enable Layout/LineLength

      let(:store_post_body) do
        '{"coverageStore":{"name":"dg548ft1892","url":"file:/geotiff/dg548ft1892.tif","enabled":true,"workspace":{"name":"druid"},"type":"GeoTIFF","_default":false,"description":"1000 Meter Resolution Bathymetry Grid of Exclusive Economic Zone (EEZ): Russian River Basin, California, 1998"}}' # rubocop:disable Layout/LineLength
      end
      let(:coverage_post_body) do
        "{\"coverage\":{\"enabled\":true,\"name\":\"dg548ft1892\",\"title\":\"1000 Meter Resolution Bathymetry Grid of Exclusive Economic Zone (EEZ): Russian River Basin, California, 1998\",\"abstract\":\"Eez1000 is a 1000 meter resolution statewide bathymetric dataset that generally covers the Exclusive Economic Zone (EEZ), an area extending 200 nautical miles from all United States possessions and trust territories. The data was adapted from isobath values ranging from 200 meters to 4800 meters below sea level; therefore nearshore depictions ARE NOT ACCURATE and \\\"flatten out\\\" between 200 meter depths and the coastline. The data is intended only for general portrayals of offshore features and depths. The Department of Fish and Game (DFG), Technical Services Branch (TSB) GIS Unit received the source data in the form of a line contour coverage (known as DFG's eezbath) from the United States Geological Survey (USGS). The contour data was converted to a TIN (triangulated irregular network) using ArcView 3D Analyst and then converted to a grid. The contour data was previously reprojected by TSB to Albers conic equal-area using standard Teale Data Center parameters. Some minor aesthetic editing was performed on peripheral areas using the ARC/INFO Grid EXPAND function. The image version was created using the ARC/INFO GRIDIMAGE function. Please see the attached metadata file \\\"eezbatcall.doc\\\" or the DFG coverage metadata \\\"eezbath.txt\\\" for further source data information.\\nThis layer can be used for watershed analysis and planning in the Russian River region of California.\",\"keywords\":{\"string\":[\"Hydrography\",\"Watersheds\",\"Inland Waters\",\"Sonoma County (Calif.)\",\"Mendocino County (Calif.)\",\"Russian River Watershed (Calif.)\"]},\"metadata_links\":[],\"metadata\":{\"cacheAgeMax\":86400,\"cachingEnabled\":true}}}" # rubocop:disable Layout/LineLength
      end
      let(:layer_put_body) do
        '{"layer":{"name":"dg548ft1892","path":"","type":"RASTER","defaultStyle":"raster","resource":{"@class":"coverage","name":"druid:dg548ft1892","href":"http://example.com/geoserver/rest/workspaces/druid/coveragestores/dg548ft1892/coverages/dg548ft1892.json"},"queryable":true,"opaque":false}}' # rubocop:disable Layout/LineLength
      end
      let(:media_type) { 'image/tiff' }

      before do
        stub_request(:get, 'http://example.com/geoserver/rest/workspaces/druid/coveragestores/dg548ft1892')
          .to_return(status: 404)
        stub_request(:get, 'http://example.com/geoserver/rest/workspaces/druid/coveragestores/dg548ft1892/coverages/dg548ft1892')
          .to_return(status: 404)
        stub_request(:get, 'http://example.com/geoserver/rest/styles/raster')
          .to_return(status: 200, body: '{"style":{"name":"raster","format":"sld","languageVersion":{"version":"1.0.0"},"filename":"raster.sld"}}')
        stub_request(:get, 'http://example.com/geoserver/rest/layers/dg548ft1892')
          .to_return(status: 200, body: '{"layer":{"name":"dg548ft1892","path":"","type":"RASTER","defaultStyle":{"name":"raster_rgb8","href":"http://example.com/geoserver/rest/styles/raster_rgb8.json"},"resource":{"@class":"coverage","name":"druid:dg548ft1892","href":"http://example.com/geoserver/rest/workspaces/druid/coveragestores/dg548ft1892/coverages/dg548ft1892.json"},"queryable":false,"opaque":false}}') # rubocop:disable Layout/LineLength
      end

      # rubocop:disable RSpec/NestedGroups
      context 'when a new coverage' do
        it 'runs without error' do
          stubbed_store_post = stub_request(:post, 'http://example.com/geoserver/rest/workspaces/druid/coveragestores')
                               .with(headers: { 'Content-Type' => 'application/json' }, body: store_post_body)
                               .to_return(status: 201)
          stubbed_coverage_post = stub_request(:post, 'http://example.com/geoserver/rest/workspaces/druid/coveragestores/dg548ft1892/coverages')
                                  .with(headers: { 'Content-Type' => 'application/json' }, body: coverage_post_body)
                                  .to_return(status: 201)
          stubbed_layer_put = stub_request(:put, 'http://example.com/geoserver/rest/layers/dg548ft1892')
                              .with(headers: { 'Content-Type' => 'application/json' }, body: layer_put_body)
                              .to_return(status: 201)
          test_perform(robot, druid)
          expect(stubbed_store_post).to have_been_requested
          expect(stubbed_coverage_post).to have_been_requested
          expect(stubbed_layer_put).to have_been_requested
        end
      end

      context 'when updating an existing coverage' do
        let(:coverage_store_response) do
          {
            coverageStore: {
              name: 'dg548ft1892',
              coverages: 'http://example.com/geoserver/restng/workspaces/druid/coveragestores/dg548ft1892/coverages.json'
            }
          }.to_json
        end
        let(:coverage_response) do
          {
            coverage: {
              abstract: 'Eez1000 is a 1000 meter resolution statewide bathymetric dataset that generally covers the Exclusive Economic Zone (EEZ)',
              description: '1000 Meter Resolution Bathymetry Grid of Exclusive Economic Zone (EEZ): Russian River Basin, California, 1998'
            }
          }.to_json
        end

        before do
          stub_request(:get, 'http://example.com/geoserver/rest/workspaces/druid/coveragestores/dg548ft1892')
            .to_return(status: 200, body: coverage_store_response)
          stub_request(:get, 'http://example.com/geoserver/rest/workspaces/druid/coveragestores/dg548ft1892/coverages/dg548ft1892')
            .to_return(status: 200, body: coverage_response)
          stub_request(:get, 'http://example.com/geoserver/rest/layers/dg548ft1892')
            .to_return(status: 200, body: '{"layer":{"name":"dg548ft1892","path":"","type":"RASTER","defaultStyle":{"name":"raster_rgb8","href":"http://example.com/geoserver/rest/styles/raster_rgb8.json"},"resource":{"@class":"coverage","name":"druid:dg548ft1892","href":"http://example.com/geoserver/rest/workspaces/druid/coveragestores/dg548ft1892/coverages/dg548ft1892.json"},"queryable":false,"opaque":false}}') # rubocop:disable Layout/LineLength
        end

        it 'runs without error' do
          stubbed_coverage_put = stub_request(:put, 'http://example.com/geoserver/rest/workspaces/druid/coveragestores/dg548ft1892/coverages/dg548ft1892')
                                 .with(headers: { 'Content-Type' => 'application/json' })
                                 .to_return(status: 201)
          stubbed_layer_put = stub_request(:put, 'http://example.com/geoserver/rest/layers/dg548ft1892')
                              .with(headers: { 'Content-Type' => 'application/json' }, body: layer_put_body)
                              .to_return(status: 201)
          test_perform(robot, druid)
          expect(stubbed_coverage_put).to have_been_requested
          expect(stubbed_layer_put).to have_been_requested
        end
      end

      context 'when raster greyscale' do
        let(:coverage) { instance_double(Geoserver::Publish::Coverage) }
        let(:coverage_store) { instance_double(Geoserver::Publish::CoverageStore) }
        let(:style) { instance_double(Geoserver::Publish::Style) }
        let(:layer) { instance_double(Geoserver::Publish::Layer) }

        before do
          allow(GisRobotSuite).to receive(:determine_raster_style).with('/geotiff/dg548ft1892.tif', logger: a_kind_of(Logger)).and_return(style_name)
          allow(Geoserver::Publish::Coverage).to receive(:new).and_return(coverage)
          allow(Geoserver::Publish::CoverageStore).to receive(:new).and_return(coverage_store)
          allow(Geoserver::Publish::Style).to receive(:new).and_return(style)
          allow(Geoserver::Publish::Layer).to receive(:new).and_return(layer)
          allow(layer).to receive(:find).and_return({ 'layer' => { 'defaultStyle' => { 'name' => "raster_#{style_name}" } } })
          allow(layer).to receive(:update)
          allow(style).to receive(:find).and_return(nil)
          allow(style).to receive(:create)
          allow(style).to receive(:update)
          allow(coverage).to receive(:find).and_return('something')
          allow(coverage).to receive(:update)
          allow(coverage_store).to receive(:find).and_return('somethingelse')
        end

        context 'when raster that matches regex' do
          let(:style_name) { 'grayscale_8_4' }
          let(:payload) do
            "
  <StyledLayerDescriptor xmlns='http://www.opengis.net/sld'
                         xmlns:ogc='http://www.opengis.net/ogc'
                         xmlns:xlink='http://www.w3.org/1999/xlink'
                         xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
                         xsi:schemaLocation='http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd'
                         version='1.0.0'>
    <UserLayer>
      <Name>raster_layer</Name>
        <UserStyle>
          <FeatureTypeStyle>
            <Rule>
              <RasterSymbolizer>
                <ColorMap>
                  <ColorMapEntry color='#000000' quantity='8' opacity='1'/>
                  <ColorMapEntry color='#FFFFFF' quantity='4' opacity='1'/>
                </ColorMap>
              </RasterSymbolizer>
            </Rule>
          </FeatureTypeStyle>
      </UserStyle>
    </UserLayer>
  </StyledLayerDescriptor>"
          end

          it 'runs without error and updates style with correct payload' do
            test_perform(robot, druid)
            expect(style).to have_received(:create).with(style_name: "raster_#{druid}", filename: "raster_#{druid}.sld")
            expect(style).to have_received(:update).with(style_name: "raster_#{druid}", filename: "raster_#{druid}.sld", payload:)
          end
        end

        context 'when raster that does not match regex' do
          let(:style_name) { 'grayscale_8_8193' }

          before { allow(style).to receive(:find).and_return('something') }

          it 'runs without error' do
            test_perform(robot, druid)
            expect(style).not_to have_received(:create).with(style_name: "raster_#{druid}", filename: nil)
            expect(style).to have_received(:find).with(style_name: 'raster_grayband')
          end
        end
      end
      # rubocop:enable RSpec/NestedGroups
    end
  end
end
