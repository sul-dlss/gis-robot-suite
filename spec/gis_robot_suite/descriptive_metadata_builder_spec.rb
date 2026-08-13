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
      it 'raises when the citation carries no date at all' do
        expect { described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:).send(:event) }.to raise_error(RuntimeError, "Publication date is missing for #{bare_druid}.")
      end

      context 'when the citation has a revision date but no publication date' do
        let(:bare_druid) { 'dt652gp5026' }

        # Cocina has no 'revision' date type; 'modification' is its term for the same
        # idea, and the one that maps to MODS dateModified.
        it 'falls back to the revision date, recorded as a modification date' do
          expect(described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:).send(:event).first[:date]).to eq(
            [{ value: '2008', encoding: { code: 'w3cdtf' }, status: 'primary', type: 'modification' }]
          )
        end
      end

      context 'when the citation has a creation date but no publication date' do
        let(:bare_druid) { 'jp529sh7785' }

        it 'falls back to the creation date, recorded as such' do
          expect(described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:).send(:event).first[:date]).to eq(
            [{ value: '2014', encoding: { code: 'w3cdtf' }, status: 'primary', type: 'creation' }]
          )
        end
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

      context 'when the record states more than one reference system' do
        let(:builder) { described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:) }
        let(:iso19139_ng) { Nokogiri::XML(reference_systems('4326', '26910')) }
        let(:synced_code) { '4326' }

        def reference_systems(*codes)
          identifiers = codes.map do |code|
            <<~XML
              <referenceSystemInfo><MD_ReferenceSystem><referenceSystemIdentifier><RS_Identifier>
                <code><gco:CharacterString>#{code}</gco:CharacterString></code>
                <codeSpace><gco:CharacterString>EPSG</gco:CharacterString></codeSpace>
              </RS_Identifier></referenceSystemIdentifier></MD_ReferenceSystem></referenceSystemInfo>
            XML
          end
          <<~XML
            <MD_Metadata xmlns="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco">
              #{identifiers.join}
            </MD_Metadata>
          XML
        end

        before do
          esri_xml = <<~XML
            <metadata>
              <refSysInfo><RefSystem><refSysID>
                <identCode Sync="#{synced_code == '4326' ? 'TRUE' : 'FALSE'}" code="4326"/>
              </refSysID></RefSystem></refSysInfo>
              <refSysInfo><RefSystem><refSysID><identCode code="26910"/></refSysID></RefSystem></refSysInfo>
            </metadata>
          XML
          allow(builder).to receive(:esri_ng).and_return(Nokogiri::XML(esri_xml))
        end

        it 'uses the one ArcGIS synced from the data instead of concatenating the two' do
          expect(builder.send(:map_projection)).to eq({ value: 'EPSG::4326', type: 'map projection' })
        end

        context 'when the ESRI metadata marks neither as synced' do
          let(:synced_code) { nil }

          it 'uses the first one stated' do
            expect(builder.send(:map_projection)).to eq({ value: 'EPSG::4326', type: 'map projection' })
          end
        end

        context 'when the synced one is stated second' do
          let(:iso19139_ng) { Nokogiri::XML(reference_systems('26910', '4326')) }

          it 'still uses the synced one' do
            expect(builder.send(:map_projection)).to eq({ value: 'EPSG::4326', type: 'map projection' })
          end
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

      context 'when the record states more than one bounding box' do
        # The authored extent and the extent ArcGIS computed from the geometry. Reading
        # both concatenated their values into "5049.38562", which failed the range check.
        let(:bare_druid) { 'pv886qw6092' }
        let(:builder) { described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:) }

        it 'uses the computed extent instead of concatenating the two' do
          expect(builder.send(:coordinates_subjects)).to eq(
            { value: 'W 124°45ʹ21ʺ--W 66°57ʹ14ʺ/N 49°23ʹ8ʺ--N 24°31ʹ6ʺ', type: 'map coordinates' }
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

    describe '.temporal_subjects' do
      let(:builder) { described_class.new(cocina_model:, bare_druid:, iso19139_ng:, logger:) }

      context 'when a date is unknown' do
        let(:bare_druid) { 'sz975gc6511' }

        it 'omits the time subject rather than parsing an empty timePosition' do
          expect(builder.send(:temporal_subjects)).to be_nil
        end
      end

      context 'when a range is open ended' do
        let(:bare_druid) { 'vm772xm4689' }

        it 'keeps the year it has, and the other extents' do
          expect(builder.send(:temporal_subjects)).to eq(
            [{ value: '2004', type: 'time', encoding: { code: 'w3cdtf' } },
             { value: '1997', type: 'time', encoding: { code: 'w3cdtf' } }]
          )
        end
      end

      context 'when a date is present but malformed' do
        # A value that will not parse is corrupt data, not an absent date, so it must
        # keep failing loudly instead of being dropped like an indeterminate position.
        # This is the shape seen in druid:gf380zd3022, where a year range was written
        # into a date: <tmPosition>1975-2012-01-01T00:00:00</tmPosition>.
        before do
          xml = <<~XML
            <MD_Metadata xmlns="http://www.isotc211.org/2005/gmd" xmlns:gml="http://www.opengis.net/gml">
              <identificationInfo>
                <MD_DataIdentification>
                  <extent><EX_Extent><temporalElement><EX_TemporalExtent><extent>
                    <gml:TimeInstant><gml:timePosition>1975-2012-01-01T00:00:00</gml:timePosition></gml:TimeInstant>
                  </extent></EX_TemporalExtent></temporalElement></EX_Extent></extent>
                </MD_DataIdentification>
              </identificationInfo>
            </MD_Metadata>
          XML
          data_id_node = Nokogiri::XML(xml).xpath('//gmd:MD_DataIdentification',
                                                  'gmd' => 'http://www.isotc211.org/2005/gmd')
          allow(builder).to receive(:data_id_node).and_return(data_id_node)
        end

        it 'raises' do
          expect { builder.send(:temporal_subjects) }.to raise_error(Date::Error, 'invalid date')
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
