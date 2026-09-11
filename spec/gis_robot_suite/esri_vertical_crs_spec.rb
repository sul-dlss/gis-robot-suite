# frozen_string_literal: true

require 'cgi'
require 'spec_helper'

RSpec.describe GisRobotSuite::EsriVerticalCrs do
  subject(:vertical_crs) { described_class.new(Nokogiri::XML(esri_xml)) }

  # ArcGIS nests the projection engine document inside <peXml> as escaped markup, and the
  # WKT's own quotes are escaped a second time within that, so build the fixture up the way
  # ArcGIS writes it rather than hand-escaping it.
  def esri_metadata_for(wkt)
    pe_xml = "<GeographicCoordinateSystem><WKT>#{CGI.escapeHTML(wkt)}</WKT><WKID>4326</WKID></GeographicCoordinateSystem>"

    <<~XML
      <metadata xml:lang="en">
        <Esri>
          <DataProperties>
            <coordRef>
              <type Sync="TRUE">Geographic</type>
              <csUnits Sync="TRUE">Angular Unit: Degree (0.017453)</csUnits>
              <peXml Sync="TRUE">#{CGI.escapeHTML(pe_xml)}</peXml>
            </coordRef>
          </DataProperties>
        </Esri>
      </metadata>
    XML
  end

  let(:horizontal_wkt) do
    'GEOGCS["GCS_WGS_1984",DATUM["D_WGS_1984",SPHEROID["WGS_1984",6378137.0,298.257223563]],' \
      'PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433],AUTHORITY["EPSG",4326]]'
  end

  context 'when the export declares a vertical coordinate system with no real datum' do
    # The shape ArcGIS writes when a Z unit was set without choosing a vertical datum,
    # which is what druid:sf815vr1246 carries.
    let(:esri_xml) do
      esri_metadata_for(
        "#{horizontal_wkt},VERTCS[\"Unknown VCS\",VDATUM[\"Unknown\"],PARAMETER[\"Vertical_Shift\",0.0]," \
        'PARAMETER["Direction",1.0],UNIT["Meter",1.0]]'
      )
    end

    it 'reports the unit ArcGIS named' do
      expect(vertical_crs).to be_unit
      expect(vertical_crs.unit_name).to eq 'Meter'
    end

    it 'maps the unit to a UCUM symbol' do
      expect(vertical_crs.unit_symbol).to eq 'm'
      expect(vertical_crs.unit_label).to eq 'm'
    end

    it 'reports the datum as unknown so callers do not assert a reference surface' do
      expect(vertical_crs.datum_name).to eq 'Unknown'
      expect(vertical_crs).not_to be_datum
    end
  end

  context 'when the export declares a vertical coordinate system with a real datum' do
    let(:esri_xml) do
      esri_metadata_for(
        "#{horizontal_wkt},VERTCS[\"NAVD_1988\",VDATUM[\"North_American_Vertical_Datum_1988\"]," \
        'PARAMETER["Vertical_Shift",0.0],PARAMETER["Direction",1.0],UNIT["Foot_US",0.3048006096012192]]'
      )
    end

    it 'reports the unit and the datum' do
      expect(vertical_crs.unit_name).to eq 'Foot_US'
      expect(vertical_crs.unit_symbol).to eq '[ft_us]'
      expect(vertical_crs.unit_label).to eq '[ft_us]'
      expect(vertical_crs.datum_name).to eq 'North_American_Vertical_Datum_1988'
      expect(vertical_crs).to be_datum
    end
  end

  context 'when the vertical unit is one we have no UCUM symbol for' do
    let(:esri_xml) do
      esri_metadata_for("#{horizontal_wkt},VERTCS[\"Unknown VCS\",VDATUM[\"Unknown\"],UNIT[\"Smoot\",1.7018]]")
    end

    it 'still reports the name ArcGIS gave it' do
      expect(vertical_crs).to be_unit
      expect(vertical_crs.unit_name).to eq 'Smoot'
      expect(vertical_crs.unit_symbol).to be_nil
    end

    it 'falls back to that name as the label' do
      expect(vertical_crs.unit_label).to eq 'Smoot'
    end
  end

  context 'when the export declares no vertical coordinate system' do
    let(:esri_xml) { esri_metadata_for(horizontal_wkt) }

    it 'reports no unit' do
      expect(vertical_crs).not_to be_unit
      expect(vertical_crs.unit_name).to be_nil
      expect(vertical_crs.unit_symbol).to be_nil
      expect(vertical_crs.unit_label).to be_nil
      expect(vertical_crs.datum_name).to be_nil
    end
  end

  context 'when the export has no coordinate reference at all' do
    let(:esri_xml) { '<metadata xml:lang="en"><Esri><DataProperties/></Esri></metadata>' }

    it 'reports no unit' do
      expect(vertical_crs).not_to be_unit
      expect(vertical_crs.unit_name).to be_nil
    end
  end

  context 'when peXml holds something that is not a coordinate system' do
    let(:esri_xml) do
      <<~XML
        <metadata xml:lang="en">
          <Esri><DataProperties><coordRef><peXml Sync="TRUE">#{CGI.escapeHTML('<Nonsense/>')}</peXml></coordRef></DataProperties></Esri>
        </metadata>
      XML
    end

    it 'reports no unit' do
      expect(vertical_crs).not_to be_unit
    end
  end
end
