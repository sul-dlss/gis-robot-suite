# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::CopyData do
  let(:robot) { described_class.new }

  describe '.perform_work' do
    let(:object_client) do
      instance_double(Dor::Services::Client::Object, find: cocina_object)
    end

    let(:cocina_object) { build(:dro, id: druid).new(description:) }

    let(:druid) { "druid:#{bare_druid}" }
    let(:output_xml_files) { Dir.glob("spec/fixtures/stage/#{bare_druid}/content/*.xml") }
    let(:output_thumbnail) { "spec/fixtures/stage/#{bare_druid}/content/preview.jpg" }
    let(:output_data_files) { [] }

    before do
      allow(Settings.geohydra).to receive(:stage).and_return('spec/fixtures/stage')
      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    end

    after do
      FileUtils.rm_f(output_xml_files)
      FileUtils.rm_rf("spec/fixtures/stage/#{bare_druid}/content")
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
          form: [
            { value: 'EPSC::3309', type: 'map projection' }
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

      let(:output_data_files) do
        [
          'spec/fixtures/stage/bb033gt0615/content/sanluisobispo1996.dbf',
          'spec/fixtures/stage/bb033gt0615/content/sanluisobispo1996.prj',
          'spec/fixtures/stage/bb033gt0615/content/sanluisobispo1996.sbn',
          'spec/fixtures/stage/bb033gt0615/content/sanluisobispo1996.shp',
          'spec/fixtures/stage/bb033gt0615/content/sanluisobispo1996.shx'
        ]
      end

      it 'copies the data' do
        test_perform(robot, druid)
        expect(output_xml_files.size).to eq 4
        # Copies the data files
        output_data_files.each do |file|
          expect(File.exist?(file)).to be true
        end
      end
    end

    context 'when GeoJSON' do
      let(:bare_druid) { 'vx812cc5548' }

      let(:description) do
        {
          title: [
            {
              value: 'Important Farmland, San Luis Obispo County, California, 1996'
            }
          ],
          form: [
            { value: 'EPSG::4326', type: 'map projection' }
          ],
          geographic: [
            {
              form: [
                {
                  value: 'application/geo+json',
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
          purl: 'https://purl.stanford.edu/vx812cc5548'
        }
      end

      let(:output_data_files) do
        [
          'spec/fixtures/stage/vx812cc5548/content/sanluisobispo1996.dbf',
          'spec/fixtures/stage/vx812cc5548/content/sanluisobispo1996.prj',
          'spec/fixtures/stage/vx812cc5548/content/sanluisobispo1996.sbn',
          'spec/fixtures/stage/vx812cc5548/content/sanluisobispo1996.shp',
          'spec/fixtures/stage/vx812cc5548/content/sanluisobispo1996.shx'
        ]
      end

      it 'copies the data' do
        test_perform(robot, druid)
        # Copies the data files
        output_data_files.each do |file|
          expect(File.exist?(file)).to be true
        end
      end
    end

    context 'when an 8-bit GeoTIFF already in EPSG:4326' do
      let(:bare_druid) { 'bb021mm7809' }

      let(:output_data_files) do
        [
          'spec/fixtures/stage/bb021mm7809/content/MCE_FI2G_2014.tfw',
          'spec/fixtures/stage/bb021mm7809/content/MCE_FI2G_2014.tif',
          'spec/fixtures/stage/bb021mm7809/content/MCE_FI2G_2014.tif.ovr',
          'spec/fixtures/stage/bb021mm7809/content/MCE_FI2G_2014.tif.vat.cpg',
          'spec/fixtures/stage/bb021mm7809/content/MCE_FI2G_2014.tif.vat.dbf'
        ]
      end

      let(:description) do
        {
          title: [
            {
              value: 'Finland 2G Mobile Coverage Explorer, 2014'
            }
          ],
          form: [
            { value: 'EPSG::4326', type: 'map projection' }
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

      after do
        FileUtils.rm_f(output_thumbnail)
      end

      it 'copies the data' do
        test_perform(robot, druid)
        expect(File.exist?(output_thumbnail)).to be true # Thumbnail is copied.
        expect(output_xml_files.size).to eq 4
        # Copies the data files
        output_data_files.each do |file|
          expect(File.exist?(file)).to be true
        end
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
          form: [
            { value: 'EPSG::4327', type: 'map projection' }
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
              subject: []
            }
          ],
          purl: 'https://purl.stanford.edu/vh469wk7989'
        }
      end

      it 'copies the data' do
        test_perform(robot, druid)
        expect(File.exist?(output_thumbnail)).to be true # Thumbnail is already in content directory.
        expect(output_xml_files.size).to eq 1
      end
    end
  end
end
