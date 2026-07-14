# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::DescriptiveMetadataBuilder do
  let(:bare_druid) { 'bh432xr2264' }
  let(:cocina_model) { build(:dro, id: "druid:#{bare_druid}") }
  let(:staging_dir) { File.join(fixture_dir, 'stage', bare_druid, 'temp') }
  let(:iso19139_xml_file) { Dir.glob("#{fixture_dir}/#{bare_druid}-iso19139.xml").first }
  let(:iso19139_ng) { Nokogiri::XML(File.read(iso19139_xml_file)) }
  let(:logger) { instance_double(Logger, info: nil, debug: nil) }

  describe '.dd2ddmmss_abs' do
    it 'converts DD to DDMMSS' do
      expect(described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:).send(:dd2ddmmss_abs, -109.758319)).to eq('109°45ʹ30ʺ')
      expect(described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:).send(:dd2ddmmss_abs, 48.999336)).to eq('48°59ʹ58ʺ')
    end
  end

  describe '.to_coordinates_ddmmss' do
    it 'converts MARC to DDMMSS' do
      expect(described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:).send(:to_coordinates_ddmmss, [-180, 180, 90, -90])).to eq('W 180°--E 180°/N 90°--S 90°')
      expect(described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:).send(:to_coordinates_ddmmss,
                                                                                         [-109.758319, -88.990844,
                                                                                          48.999336, 29.423028])).to eq('W 109°45ʹ30ʺ--W 88°59ʹ27ʺ/N 48°59ʹ58ʺ--N 29°25ʹ23ʺ')
    end

    it 'handles bad arguments' do
      expect { described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:).send(:to_coordinates_ddmmss, [-185, 185, 95, -95]) }.to raise_error(ArgumentError)
    end
  end

  context 'when data is missing' do
    let(:bare_druid) { 'bb333cc4444' }

    describe '.title' do
      it 'raises when title missing' do
        expect { described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:).send(:title) }.to raise_error(RuntimeError, "Title is missing for #{bare_druid}.")
      end
    end

    describe '.event' do
      it 'raises when publication is missing' do
        expect { described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:).send(:event) }.to raise_error(RuntimeError, "Publication date is missing for #{bare_druid}.")
      end
    end

    describe '.admin_identifier' do
      it 'raises when admin identifier is missing' do
        expect { described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:).send(:admin_identifier) }
          .to raise_error(RuntimeError, "identifier not found in '//gmd:MD_Metadata/gmd:fileIdentifier/gco:CharacterString'")
      end
    end

    describe '.map_projection' do
      it 'raises when map projection data is missing' do
        expect do
          described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:).send(:map_projection)
        end.to raise_error(RuntimeError, "Map projection is missing for #{bare_druid}.")
      end

      context 'when projection is missing from metadata but fallback works for vectors' do
        let(:builder) { described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:) }

        before do
          allow(builder).to receive_messages(vector_filepath: '/path/to/vector.shp', raster_filepath: nil)
          allow(GisRobotSuite).to receive(:run_system_command).with(/gdal info .* -f json/, any_args).and_return(
            { stdout_str: '{"layers":[{"geometryFields":[{"coordinateSystem":{"projjson":{"id":{"authority":"EPSG","code":3309}}}}]}]}' }
          )
        end

        it 'falls back to gdal info for vectors' do
          expect(builder.send(:map_projection)).to eq({ value: 'EPSG::3309', type: 'map projection' })
        end
      end

      context 'when projection is missing from metadata but fallback works for rasters' do
        let(:builder) { described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:) }

        before do
          allow(builder).to receive_messages(vector_filepath: nil, raster_filepath: '/path/to/raster.tif')
          allow(GisRobotSuite).to receive(:run_system_command).with(/gdal info .* -f json/, any_args).and_return(
            { stdout_str: '{"stac":{"proj:projjson":{"id":{"authority":"EPSG","code":4326}}}}' }
          )
        end

        it 'falls back to gdal info for rasters' do
          expect(builder.send(:map_projection)).to eq({ value: 'EPSG::4326', type: 'map projection' })
        end
      end

      context 'when projection is missing from metadata and fallback parsing falls back to WKT' do
        let(:builder) { described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:) }

        before do
          allow(builder).to receive_messages(vector_filepath: nil, raster_filepath: '/path/to/raster.tif')
          allow(GisRobotSuite).to receive(:run_system_command).with(/gdal info .* -f json/, any_args).and_return(
            { stdout_str: '{"coordinateSystem":{"wkt":"GEOGCRS[\"WGS 84\", ID[\"EPSG\",4326]]"}}' }
          )
        end

        it 'parses from WKT' do
          expect(builder.send(:map_projection)).to eq({ value: 'EPSG::4326', type: 'map projection' })
        end
      end

      context 'when the projection has a name but no ID' do
        let(:builder) { described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:) }

        before do
          allow(builder).to receive_messages(vector_filepath: '/path/to/vector.shp', raster_filepath: nil)
          allow(GisRobotSuite).to receive(:run_system_command).with(/gdal info .* -f json/, any_args).and_return(
            { stdout_str: '{"coordinateSystem":{"wkt":"PROJCRS[\"California Albers\"]","projjson":{"name":"California Albers"}}}' }
          )
        end

        it 'uses the name instead' do
          expect(builder.send(:map_projection)).to eq({ value: 'California Albers', type: 'map projection' })
        end
      end
    end

    describe '.coordinates_subjects' do
      context 'when coordinates are present in the XML' do
        let(:builder) { described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:) }

        it 'returns map coordinates from metadata' do
          expect(builder.send(:coordinates_subjects)).to eq(
            { value: 'W 158°1ʹ3ʺ--W 65°35ʹ41ʺ/N 64°51ʹ16ʺ--N 18°7ʺ', type: 'map coordinates' }
          )
        end
      end

      context 'when coordinates are missing and no fallback files are present' do
        let(:builder) { described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:) }

        before do
          allow(builder).to receive(:data_id_node).and_return(Nokogiri::XML('<empty/>'))
          allow(builder).to receive_messages(vector_filepath: nil, raster_filepath: nil)
        end

        it 'returns nil' do
          expect(builder.send(:coordinates_subjects)).to be_nil
        end
      end

      context 'when coordinates are missing from metadata but fallback works for vectors' do
        let(:builder) { described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:) }

        before do
          allow(builder).to receive(:data_id_node).and_return(Nokogiri::XML('<empty/>'))
          allow(builder).to receive_messages(vector_filepath: '/path/to/vector.shp', raster_filepath: nil)
          vector_json = {
            layers: [
              {
                geometryFields: [
                  {
                    coordinateSystem: {
                      projjson: {
                        bbox: {
                          south_latitude: 32.53,
                          west_longitude: -124.45,
                          north_latitude: 42.01,
                          east_longitude: -114.12
                        }
                      }
                    }
                  }
                ]
              }
            ]
          }.to_json
          allow(GisRobotSuite).to receive(:run_system_command).with(/gdal info .* -f json/, any_args).and_return(
            { stdout_str: vector_json }
          )
        end

        it 'falls back to gdal info for vectors' do
          expect(builder.send(:coordinates_subjects)).to eq(
            { value: 'W 124°27ʹ--W 114°7ʹ12ʺ/N 42°36ʺ--N 32°31ʹ48ʺ', type: 'map coordinates' }
          )
        end
      end

      context 'when coordinates are missing from metadata but fallback works for rasters' do
        let(:builder) { described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:) }

        before do
          allow(builder).to receive(:data_id_node).and_return(Nokogiri::XML('<empty/>'))
          allow(builder).to receive_messages(vector_filepath: nil, raster_filepath: '/path/to/raster.tif')
          raster_json = {
            stac: {
              'proj:projjson': {
                bbox: {
                  south_latitude: 49.75,
                  west_longitude: -9.01,
                  north_latitude: 61.01,
                  east_longitude: 2.01
                }
              }
            }
          }.to_json
          allow(GisRobotSuite).to receive(:run_system_command).with(/gdal info .* -f json/, any_args).and_return(
            { stdout_str: raster_json }
          )
        end

        it 'falls back to gdal info for rasters' do
          expect(builder.send(:coordinates_subjects)).to eq(
            { value: 'W 9°36ʺ--E 2°36ʺ/N 61°36ʺ--N 49°45ʹ', type: 'map coordinates' }
          )
        end
      end
    end

    describe '.language' do
      it 'raises when language is missing' do
        expect { described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:).send(:language) }.to raise_error(RuntimeError, "Language missing for #{bare_druid}.")
      end
    end

    describe '.abstract_note' do
      it 'raises when abstract is missing' do
        expect { described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:).send(:abstract_note) }.to raise_error(RuntimeError, "Abstract missing for #{bare_druid}.")
      end
    end
  end
end
