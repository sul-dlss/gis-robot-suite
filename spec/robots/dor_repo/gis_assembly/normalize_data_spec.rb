# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::NormalizeData do
  let(:robot) { described_class.new }

  describe '.perform_work' do
    let(:object_client) do
      instance_double(Dor::Services::Client::Object, find: cocina_object)
    end

    let(:cocina_object) { build(:dro, id: druid).new(description:) }

    let(:wkt) do
      'GEOGCS["WGS 84", DATUM["WGS_1984", SPHEROID["WGS 84",6378137,298.257223563, AUTHORITY["EPSG","7030"]], AUTHORITY["EPSG","6326"]], PRIMEM["Greenwich",0, AUTHORITY["EPSG","8901"]], UNIT["degree",0.0174532925199433, AUTHORITY["EPSG","9122"]], AUTHORITY["EPSG","4326"]]' # rubocop:disable Layout/LineLength
    end

    let(:druid) { "druid:#{bare_druid}" }
    let(:output_zip) { "spec/fixtures/stage/#{bare_druid}/content/data_EPSG_4326.zip" }

    before do
      allow(Settings.geohydra).to receive(:stage).and_return('spec/fixtures/stage')
      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
      allow(Kernel).to receive(:system).and_call_original

      stub_request(:get, 'https://spatialreference.org/ref/epsg/4326/prettywkt/')
        .to_return(status: 200, body: wkt, headers: {})
    end

    after do
      FileUtils.rm_f(output_zip)
    end

    context 'when a Shapefile' do
      let(:bare_druid) { 'bb033gt0615' }

      let(:description) do
        {
          title: [
            {
              value: 'Important Farmland, San Luis Obispo County, California, 1996'
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
              ]
            }
          ],
          purl: 'https://purl.stanford.edu/bb033gt0615'
        }
      end

      it 'normalizes the data' do
        test_perform(robot, druid)
        expect(File.exist?(output_zip)).to be true
        Zip::File.open(output_zip) do |zip_file|
          expect(zip_file.entries.size).to eq 4
          # Will raise if not present
          zip_file.get_entry('sanluisobispo1996.dbf')
          zip_file.get_entry('sanluisobispo1996.prj')
          zip_file.get_entry('sanluisobispo1996.shp')
          zip_file.get_entry('sanluisobispo1996.shx')
        end
        # Reproject
        expect(Kernel).to have_received(:system).with(
          "env SHAPE_ENCODING= ogr2ogr -progress -t_srs 'GEOGCS[\"WGS 84\", DATUM[\"WGS_1984\", SPHEROID[\"WGS 84\",6378137,298.257223563, AUTHORITY[\"EPSG\",\"7030\"]], AUTHORITY[\"EPSG\",\"6326\"]], PRIMEM[\"Greenwich\",0, AUTHORITY[\"EPSG\",\"8901\"]], UNIT[\"degree\",0.0174532925199433, AUTHORITY[\"EPSG\",\"9122\"]], AUTHORITY[\"EPSG\",\"4326\"]]' '/tmp/normalize_bb033gt0615/EPSG_4326/sanluisobispo1996.shp' '/tmp/normalize_bb033gt0615/sanluisobispo1996.shp'" # rubocop:disable Layout/LineLength
        )
      end
    end

    context 'when an 8-bit GeoTIFF' do
      let(:bare_druid) { 'bb021mm7809' }

      let(:description) do
        {
          title: [
            {
              value: 'Finland 2G Mobile Coverage Explorer, 2014'
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
                      value: '16.1179474',
                      type: 'west'
                    },
                    {
                      value: '59.2022116',
                      type: 'south'
                    },
                    {
                      value: '32.2367687',
                      type: 'east'
                    },
                    {
                      value: '70.6126121',
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
                  value: 'Finland',
                  type: 'coverage',
                  valueLanguage: {
                    code: 'eng'
                  }
                }
              ]
            }
          ],
          purl: 'https://purl.stanford.edu/bb021mm7809'
        }
      end

      it 'normalizes the data' do
        test_perform(robot, druid)
        expect(File.exist?(output_zip)).to be true
        Zip::File.open(output_zip) do |zip_file|
          expect(zip_file.entries.size).to eq 2
          # Will raise if not present
          zip_file.get_entry('MCE_FI2G_2014.tif')
          zip_file.get_entry('MCE_FI2G_2014.tif.aux.xml')
        end
        # Reproject
        expect(Kernel).to have_received(:system).with(
          "gdalwarp -r bilinear -t_srs EPSG:4326 /tmp/normalize_bb021mm7809/MCE_FI2G_2014.tif /tmp/normalize_bb021mm7809/EPSG_4326/MCE_FI2G_2014_uncompressed.tif -co 'COMPRESS=NONE'"
        )
        # Compress
        expect(Kernel).to have_received(:system).with(
          "gdal_translate -a_srs EPSG:4326 /tmp/normalize_bb021mm7809/EPSG_4326/MCE_FI2G_2014_uncompressed.tif /tmp/normalize_bb021mm7809/EPSG_4326/MCE_FI2G_2014.tif -co 'COMPRESS=LZW'" # rubocop:disable Layout/LineLength
        )
        # Convert to RGB
        expect(Kernel).to have_received(:system).with(
          "gdal_translate -expand rgb /tmp/normalize_bb021mm7809/raw8bit.tif /tmp/normalize_bb021mm7809/EPSG_4326/MCE_FI2G_2014.tif -co 'COMPRESS=LZW'"
        )
        # Stats
        expect(Kernel).to have_received(:system).with(
          'gdalinfo -mm -stats -norat -noct /tmp/normalize_bb021mm7809/EPSG_4326/MCE_FI2G_2014.tif'
        )
      end
    end

    context 'when an ArcGRID' do
      let(:bare_druid) { 'vh469wk7989' }

      let(:description) do
        {
          title: [
            {
              value: '10-Meter Hillshade Grid: Albion River Watershed, California, 2004'
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
                  value: 'ArcGRID',
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
                      value: '-123.7787444',
                      type: 'west'
                    },
                    {
                      value: '39.2053384',
                      type: 'south'
                    },
                    {
                      value: '-123.5370228',
                      type: 'east'
                    },
                    {
                      value: '39.3055103',
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
          purl: 'https://purl.stanford.edu/vh469wk7989'
        }
      end

      it 'normalizes the data' do
        test_perform(robot, druid)
        expect(File.exist?(output_zip)).to be true
        Zip::File.open(output_zip) do |zip_file|
          expect(zip_file.entries.size).to eq 2
          # Will raise if not present
          zip_file.get_entry('h_shade.tif')
          zip_file.get_entry('h_shade.tif.aux.xml')
        end
        # Reproject
        expect(Kernel).to have_received(:system).with(
          "gdalwarp -r bilinear -t_srs EPSG:4326 /tmp/normalize_vh469wk7989/h_shade /tmp/normalize_vh469wk7989/EPSG_4326/h_shade_uncompressed.tif -co 'COMPRESS=NONE'"
        )
        # Compress
        expect(Kernel).to have_received(:system).with(
          "gdal_translate -a_srs EPSG:4326 /tmp/normalize_vh469wk7989/EPSG_4326/h_shade_uncompressed.tif /tmp/normalize_vh469wk7989/EPSG_4326/h_shade.tif -co 'COMPRESS=LZW'"
        )
        # Not convert to RGB
        expect(Kernel).not_to have_received(:system).with(
          "gdal_translate -expand rgb /tmp/normalize_vh469wk7989/raw8bit.tif /tmp/normalize_vh469wk7989/EPSG_4326/h_shade.tif -co 'COMPRESS=LZW'"
        )
        # Stats
        expect(Kernel).to have_received(:system).with(
          'gdalinfo -mm -stats -norat -noct /tmp/normalize_vh469wk7989/EPSG_4326/h_shade.tif'
        )
      end
    end
  end
end