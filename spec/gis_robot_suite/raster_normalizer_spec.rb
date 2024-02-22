# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::RasterNormalizer do
  let(:normalizer) { described_class.new(logger:, cocina_object:, rootdir:) }

  let(:druid) { "druid:#{bare_druid}" }

  let(:tmpdir) { "/tmp/normalizeraster_#{bare_druid}" }

  let(:cocina_object) { build(:dro, id: druid).new(description:) }

  let(:logger) { instance_double(Logger, debug: nil, info: nil) }

  let(:rootdir) { GisRobotSuite.locate_druid_path bare_druid, type: :workspace }

  before do
    FileUtils.mkdir_p(tmpdir)
    allow(GisRobotSuite).to receive(:run_system_command).and_call_original
  end

  after do
    normalizer.cleanup
  end

  describe '#normalize' do
    context 'when an 8-bit GeoTIFF already in EPSG:4326' do
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
        expect(normalizer.normalize).to eq(tmpdir)
        expect(File).to exist(File.join(tmpdir, 'MCE_FI2G_2014.tif'))

        # Does not reproject
        expect(GisRobotSuite).not_to have_received(:run_system_command).with(
          "gdalwarp -r bilinear -t_srs EPSG:4326 spec/fixtures/workspace/bb/021/mm/7809/bb021mm7809/content/MCE_FI2G_2014.tif /tmp/normalizeraster_bb021mm7809/MCE_FI2G_2014_uncompressed.tif -co 'COMPRESS=NONE'", # rubocop:disable Layout/LineLength
          logger:
        )
        # Compress
        expect(GisRobotSuite).to have_received(:run_system_command).with(
          "gdal_translate -a_srs EPSG:4326 spec/fixtures/workspace/bb/021/mm/7809/bb021mm7809/content/MCE_FI2G_2014.tif /tmp/normalizeraster_bb021mm7809/MCE_FI2G_2014.tif -co 'COMPRESS=LZW'", # rubocop:disable Layout/LineLength
          logger:
        )
        # Convert to RGB
        expect(GisRobotSuite).to have_received(:run_system_command).with(
          "gdal_translate -expand rgb /tmp/normalizeraster_bb021mm7809/raw8bit.tif /tmp/normalizeraster_bb021mm7809/MCE_FI2G_2014.tif -co 'COMPRESS=LZW'",
          logger:
        )
        # Adds an alpha channel
        expect(GisRobotSuite).to have_received(:run_system_command).with(
          "gdalwarp -dstalpha -co 'COMPRESS=LZW' -dstnodata 0 /tmp/normalizeraster_bb021mm7809/MCE_FI2G_2014.tif /tmp/normalizeraster_bb021mm7809/MCE_FI2G_2014_alpha.tif",
          logger:
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
                    code: 'EPSG:4327'
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
        expect(normalizer.normalize).to eq(tmpdir)
        expect(File).to exist(File.join(tmpdir, 'h_shade.tif'))

        # Reprojects
        expect(GisRobotSuite).to have_received(:run_system_command).with(
          "gdalwarp -r bilinear -t_srs EPSG:4326 spec/fixtures/workspace/vh/469/wk/7989/vh469wk7989/content/h_shade /tmp/normalizeraster_vh469wk7989/h_shade_uncompressed.tif -co 'COMPRESS=NONE'", # rubocop:disable Layout/LineLength
          logger:
        )
        # Compress
        expect(GisRobotSuite).to have_received(:run_system_command).with(
          "gdal_translate -a_srs EPSG:4326 /tmp/normalizeraster_vh469wk7989/h_shade_uncompressed.tif /tmp/normalizeraster_vh469wk7989/h_shade.tif -co 'COMPRESS=LZW'",
          logger:
        )
        # Not convert to RGB
        expect(GisRobotSuite).not_to have_received(:run_system_command).with(
          "gdal_translate -expand rgb /tmp/normalizeraster_vh469wk7989/raw8bit.tif /tmp/normalizeraster_vh469wk7989/h_shade.tif -co 'COMPRESS=LZW'",
          logger:
        )
      end
    end
  end
end
