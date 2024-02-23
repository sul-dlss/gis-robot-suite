# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::DescriptiveMetadataBuilder do
  let(:bare_druid) { 'bh432xr2264' }
  let(:staging_dir) { File.join(fixture_dir, 'stage', bare_druid, 'temp') }
  let(:iso19139_xml_file) { Dir.glob("#{fixture_dir}/#{bare_druid}-iso19139.xml").first }
  let(:iso19139_ng_xml) { Nokogiri::XML(File.read(iso19139_xml_file)) }

  describe '.dd2ddmmss_abs' do
    it 'converts DD to DDMMSS' do
      expect(described_class.new(bare_druid, iso19139_ng_xml).send(:dd2ddmmss_abs, -109.758319)).to eq('109°45ʹ30ʺ')
      expect(described_class.new(bare_druid, iso19139_ng_xml).send(:dd2ddmmss_abs, 48.999336)).to eq('48°59ʹ58ʺ')
    end
  end

  describe '.to_coordinates_ddmmss' do
    it 'converts MARC to DDMMSS' do
      expect(described_class.new(bare_druid, iso19139_ng_xml).send(:to_coordinates_ddmmss, [-180, 180, 90, -90])).to eq('W 180°--E 180°/N 90°--S 90°')
      expect(described_class.new(bare_druid, iso19139_ng_xml).send(:to_coordinates_ddmmss,
                                                                   [-109.758319, -88.990844, 48.999336,
                                                                    29.423028])).to eq('W 109°45ʹ30ʺ--W 88°59ʹ27ʺ/N 48°59ʹ58ʺ--N 29°25ʹ23ʺ')
    end

    it 'handles bad arguments' do
      expect { described_class.new(bare_druid, iso19139_ng_xml).send(:to_coordinates_ddmmss, [-185, 185, 95, -95]) }.to raise_error(ArgumentError)
    end
  end

  context 'when data is missing' do
    let(:bare_druid) { 'bb333cc4444' }

    describe '.title' do
      it 'raises when title missing' do
        expect { described_class.new(bare_druid, iso19139_ng_xml).send(:title) }.to raise_error(RuntimeError, "Title is missing for #{bare_druid}.")
      end
    end

    describe '.event' do
      it 'raises when publication is missing' do
        expect { described_class.new(bare_druid, iso19139_ng_xml).send(:event) }.to raise_error(RuntimeError, "Publication date is missing for #{bare_druid}.")
      end
    end

    describe '.admin_identifier' do
      it 'raises when admin identifier is missing' do
        expect { described_class.new(bare_druid, iso19139_ng_xml).send(:admin_identifier) }
          .to raise_error(RuntimeError, "identifier not found in '//gmd:MD_Metadata/gmd:fileIdentifier/gco:CharacterString'")
      end
    end

    describe '.map_projection' do
      it 'raises when map projection data is missing' do
        expect { described_class.new(bare_druid, iso19139_ng_xml).send(:map_projection) }.to raise_error(RuntimeError, "Map projection is missing for #{bare_druid}.")
      end
    end

    describe '.language' do
      it 'raises when language is missing' do
        expect { described_class.new(bare_druid, iso19139_ng_xml).send(:language) }.to raise_error(RuntimeError, "Language missing for #{bare_druid}.")
      end
    end

    describe '.abstract_note' do
      it 'raises when abstract is missing' do
        expect { described_class.new(bare_druid, iso19139_ng_xml).send(:abstract_note) }.to raise_error(RuntimeError, "Abstract missing for #{bare_druid}.")
      end
    end
  end
end
