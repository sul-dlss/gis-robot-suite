# frozen_string_literal: true

require 'cgi'
require 'spec_helper'
require 'tmpdir'

RSpec.describe GisRobotSuite::Iso19139BandUnits do
  subject(:apply) { described_class.apply(iso19139_file, esri_ng: Nokogiri::XML(esri_xml), logger:) }

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

  def esri_metadata(vertcs: nil, quantity_type: 'length')
    wkt = ['GEOGCS["GCS_WGS_1984",UNIT["Degree",0.0174532925199433]]', vertcs].compact.join(',')
    pe_xml = "<GeographicCoordinateSystem><WKT>#{CGI.escapeHTML(wkt)}</WKT></GeographicCoordinateSystem>"
    uom = quantity_type ? %(<UOM type="#{quantity_type}"/>) : '<UOM/>'

    <<~XML
      <metadata xml:lang="en">
        <Esri><DataProperties><coordRef><peXml Sync="TRUE">#{CGI.escapeHTML(pe_xml)}</peXml></coordRef></DataProperties></Esri>
        <contInfo><ImgDesc><covDim><Band><valUnit>#{uom}</valUnit></Band></covDim></ImgDesc></contInfo>
      </metadata>
    XML
  end

  context 'when the export declares a vertical unit' do
    let(:esri_xml) do
      esri_metadata(vertcs: 'VERTCS["Unknown VCS",VDATUM["Unknown"],PARAMETER["Direction",1.0],UNIT["Meter",1.0]]')
    end

    before { apply }

    it 'records the unit in UCUM terms, keeping the name ArcGIS used' do
      expect(units.at_xpath('gml:UnitDefinition/gml:identifier', namespaces).text).to eq 'm'
      expect(units.at_xpath('gml:UnitDefinition/gml:identifier/@codeSpace', namespaces).value)
        .to eq 'http://www.opengis.net/def/uom/UCUM/'
      expect(units.at_xpath('gml:UnitDefinition/gml:name', namespaces).text).to eq 'Meter'
      expect(units.at_xpath('gml:UnitDefinition/gml:catalogSymbol', namespaces).text).to eq 'm'
    end

    it 'carries the quantity kind the ESRI metadata recorded' do
      expect(units.at_xpath('gml:UnitDefinition/gml:quantityType', namespaces).text).to eq 'length'
    end

    it 'keeps the gml:id the stylesheet generated' do
      expect(units.at_xpath('gml:UnitDefinition/@gml:id', namespaces).value).to eq 'idp84848'
    end

    it 'drops the placeholder identifier' do
      expect(iso19139_file.read).not_to include 'Unified Code of Units of Measure'
    end

    it 'notes that the unit carries no reference surface' do
      expect(logger).to have_received(:info).with(/recording band units as Meter/)
      expect(logger).to have_received(:info).with(/vertical datum is "Unknown"/)
    end
  end

  context 'when the vertical unit has no UCUM symbol' do
    let(:esri_xml) { esri_metadata(vertcs: 'VERTCS["Unknown VCS",VDATUM["Unknown"],UNIT["Smoot",1.7018]]') }

    before { apply }

    it 'keeps the unit and reports it as ESRI' do
      expect(units.at_xpath('gml:UnitDefinition/gml:identifier', namespaces).text).to eq 'Smoot'
      expect(units.at_xpath('gml:UnitDefinition/gml:identifier/@codeSpace', namespaces).value).to eq 'ESRI'
      expect(units.at_xpath('gml:UnitDefinition/gml:catalogSymbol', namespaces)).to be_nil
    end
  end

  context 'when the ESRI metadata records no quantity kind' do
    let(:esri_xml) do
      esri_metadata(vertcs: 'VERTCS["Unknown VCS",VDATUM["Unknown"],UNIT["Meter",1.0]]', quantity_type: nil)
    end

    before { apply }

    it 'omits the quantity type rather than guessing one' do
      expect(units.at_xpath('gml:UnitDefinition/gml:quantityType', namespaces)).to be_nil
      expect(units.at_xpath('gml:UnitDefinition/gml:identifier', namespaces).text).to eq 'm'
    end
  end

  context 'when the export declares no vertical coordinate system' do
    let(:esri_xml) { esri_metadata }

    before { apply }

    it 'records the units as missing instead of naming a code system' do
      expect(units.at_xpath('@gco:nilReason', namespaces).value).to eq 'missing'
      expect(units.at_xpath('gml:UnitDefinition', namespaces)).to be_nil
    end

    it 'does not leave the useless placeholder behind' do
      expect(iso19139_file.read).not_to include 'Unified Code of Units of Measure'
    end

    it 'says how many bands it nilled' do
      expect(logger).to have_received(:info).with(/no vertical coordinate system declared; recording 1 band unit\(s\) as missing/)
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
    let(:esri_xml) { esri_metadata(vertcs: 'VERTCS["Unknown VCS",VDATUM["Unknown"],UNIT["Meter",1.0]]') }

    before { apply }

    it 'leaves it alone rather than overwriting it from the vertical CRS' do
      expect(units.at_xpath('gml:UnitDefinition/gml:identifier', namespaces).text).to eq 'ft'
    end
  end

  context 'when the units are already recorded as missing' do
    let(:iso19139_xml) { iso19139_with('<units gco:nilReason="missing"/>') }
    let(:esri_xml) { esri_metadata }

    it 'leaves the document untouched' do
      expect { apply }.not_to change(iso19139_file, :read)
    end
  end

  context 'when the document has no bands' do
    let(:iso19139_xml) do
      '<MD_Metadata xmlns="http://www.isotc211.org/2005/gmd"><contentInfo/></MD_Metadata>'
    end
    let(:esri_xml) { esri_metadata(vertcs: 'VERTCS["Unknown VCS",VDATUM["Unknown"],UNIT["Meter",1.0]]') }

    it 'leaves the document untouched' do
      expect { apply }.not_to change(iso19139_file, :read)
    end
  end
end
