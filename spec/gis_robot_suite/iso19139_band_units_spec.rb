# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe GisRobotSuite::Iso19139BandUnits do
  subject(:apply) { described_class.apply(iso19139_file, logger:) }

  let(:logger) { instance_double(Logger, info: nil, warn: nil, debug: nil, error: nil) }
  let(:iso19139_file) do
    (Pathname(Dir.mktmpdir) / 'MONT_DEM-iso19139.xml').tap { |path| path.write(iso19139_xml) }
  end
  let(:iso19139_xml) { iso19139_with(placeholder_units) }
  let(:patched) { Nokogiri::XML(iso19139_file.read) }
  let(:units) { patched.at_xpath('//gmd:MD_Band/gmd:units', namespaces) }
  let(:namespaces) do
    {
      'gmd' => 'http://www.isotc211.org/2005/gmd',
      'gco' => 'http://www.isotc211.org/2005/gco',
      'gml' => 'http://www.opengis.net/gml'
    }
  end
  # The units element the stylesheet emits: it looks populated, but the identifier is the
  # fixed literal substituted when the source ESRI metadata named no unit.
  let(:placeholder_units) do
    <<~XML
      <units>
        <gml:UnitDefinition gml:id="idp84848">
          <gml:identifier codeSpace="GML_UomSymbol">Unified Code of Units of Measure</gml:identifier>
        </gml:UnitDefinition>
      </units>
    XML
  end

  after { FileUtils.rm_rf(iso19139_file.dirname) }

  def iso19139_with(units_xml)
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <MD_Metadata xmlns="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gml="http://www.opengis.net/gml">
        <contentInfo>
          <MD_ImageDescription>
            <dimension>
              <MD_Band>
                <descriptor>
                  <gco:CharacterString>MONT_DEM</gco:CharacterString>
                </descriptor>
                #{units_xml}
                <bitsPerValue>
                  <gco:Integer>32</gco:Integer>
                </bitsPerValue>
              </MD_Band>
            </dimension>
          </MD_ImageDescription>
        </contentInfo>
      </MD_Metadata>
    XML
  end

  context 'with the placeholder the stylesheet emits' do
    before { apply }

    it 'records the units as missing instead of naming a code system' do
      expect(units.at_xpath('@gco:nilReason', namespaces).value).to eq 'missing'
      expect(units.at_xpath('gml:UnitDefinition', namespaces)).to be_nil
    end

    it 'does not leave the placeholder behind' do
      expect(iso19139_file.read).not_to include 'Unified Code of Units of Measure'
    end

    it 'says how many bands it nilled' do
      expect(logger).to have_received(:info).with(/recording 1 band unit\(s\) as missing/)
    end
  end

  context 'with a band whose units element has no unit definition at all' do
    let(:iso19139_xml) { iso19139_with('<units/>') }

    before { apply }

    it 'records the units as missing' do
      expect(units.at_xpath('@gco:nilReason', namespaces).value).to eq 'missing'
    end
  end

  context 'with more than one band' do
    let(:iso19139_xml) do
      iso19139_with(placeholder_units).sub('</dimension>', <<~XML)
        </dimension>
        <dimension>
          <MD_Band>
            <descriptor><gco:CharacterString>Band_2</gco:CharacterString></descriptor>
            #{placeholder_units}
          </MD_Band>
        </dimension>
      XML
    end

    before { apply }

    it 'nils every band' do
      all_units = patched.xpath('//gmd:MD_Band/gmd:units', namespaces)
      expect(all_units.size).to eq 2
      expect(all_units.map { |u| u.at_xpath('@gco:nilReason', namespaces)&.value }).to all(eq('missing'))
    end
  end

  context 'when the stylesheet managed to record a real unit' do
    let(:iso19139_xml) do
      iso19139_with(<<~XML)
        <units>
          <gml:UnitDefinition gml:id="idp1">
            <gml:identifier codeSpace="http://aurora.regenstrief.org/UCUM">ft</gml:identifier>
          </gml:UnitDefinition>
        </units>
      XML
    end

    before { apply }

    it 'leaves it alone' do
      expect(units.at_xpath('gml:UnitDefinition/gml:identifier', namespaces).text).to eq 'ft'
    end
  end

  context 'when the units are already recorded as missing' do
    let(:iso19139_xml) { iso19139_with('<units gco:nilReason="missing"/>') }

    it 'leaves the document untouched' do
      expect { apply }.not_to change(iso19139_file, :read)
    end
  end

  context 'when the document has no bands' do
    let(:iso19139_xml) { '<MD_Metadata xmlns="http://www.isotc211.org/2005/gmd"><contentInfo/></MD_Metadata>' }

    it 'leaves the document untouched' do
      expect { apply }.not_to change(iso19139_file, :read)
    end
  end
end
