# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::Iso19139BoundingBox do
  let(:namespaces) { { 'gmd' => 'http://www.isotc211.org/2005/gmd', 'gco' => 'http://www.isotc211.org/2005/gco' } }
  let(:bounding_box) { GisRobotSuite::BoundingBox.new(west: 169.5207977294923, east: -143.0662994384765, north: 4.69949197769165, south: -17.852113723754883) }
  let(:workdir) { Dir.mktmpdir }
  let(:iso19139_file) { File.join(workdir, 'test-iso19139.xml') }
  let(:iso19139_ng) { Nokogiri::XML(File.read(iso19139_file)) }

  after { FileUtils.rm_rf(workdir) }

  def boxes
    iso19139_ng.xpath('//gmd:EX_GeographicBoundingBox', namespaces)
  end

  describe '.apply' do
    before do
      File.write(iso19139_file, source)
      described_class.apply(iso19139_file, bounding_box:)
    end

    context 'when the record states the extent authored in ArcGIS and the one it synced' do
      let(:source) { File.read(File.join(fixture_dir, 'pv886qw6092-iso19139.xml')) }

      it 'replaces both with the one computed from the data' do
        expect(boxes.size).to eq 1
        expect(described_class.read(iso19139_ng)).to eq bounding_box
      end

      it 'drops the extents left empty, keeping the one with the temporal extent' do
        extents = iso19139_ng.xpath('//gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent', namespaces)
        expect(extents.map { |extent| extent.element_children.map(&:name) })
          .to eq [%w[geographicElement], %w[description temporalElement]]
      end

      it 'states that the box includes the data, then the bounds in schema order' do
        expect(boxes.first.element_children.map(&:name))
          .to eq %w[extentTypeCode westBoundLongitude eastBoundLongitude southBoundLatitude northBoundLatitude]
        expect(boxes.first.at_xpath('gmd:extentTypeCode/gco:Boolean', namespaces).text).to eq 'true'
      end
    end

    context 'when the extent with the box also has a description and a temporal extent' do
      let(:source) do
        <<~XML
          <MD_Metadata xmlns="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco">
            <identificationInfo>
              <MD_DataIdentification>
                <extent>
                  <EX_Extent>
                    <description><gco:CharacterString>Kiribati</gco:CharacterString></description>
                    <geographicElement>
                      <EX_GeographicBoundingBox>
                        <westBoundLongitude><gco:Decimal>-174.543396</gco:Decimal></westBoundLongitude>
                        <eastBoundLongitude><gco:Decimal>176.848694</gco:Decimal></eastBoundLongitude>
                        <southBoundLatitude><gco:Decimal>-17.852114</gco:Decimal></southBoundLatitude>
                        <northBoundLatitude><gco:Decimal>4.699492</gco:Decimal></northBoundLatitude>
                      </EX_GeographicBoundingBox>
                    </geographicElement>
                    <temporalElement/>
                  </EX_Extent>
                </extent>
              </MD_DataIdentification>
            </identificationInfo>
          </MD_Metadata>
        XML
      end

      it 'puts the box between them, as EX_Extent orders its elements' do
        extent = iso19139_ng.at_xpath('//gmd:EX_Extent', namespaces)
        expect(extent.element_children.map(&:name)).to eq %w[description geographicElement temporalElement]
        expect(described_class.read(iso19139_ng)).to eq bounding_box
      end
    end

    context 'when the ArcGIS metadata had a temporal extent but no box to copy' do
      let(:source) do
        <<~XML
          <MD_Metadata xmlns="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco">
            <identificationInfo>
              <MD_DataIdentification>
                <extent>
                  <EX_Extent>
                    <description><gco:CharacterString>publication date</gco:CharacterString></description>
                    <temporalElement/>
                  </EX_Extent>
                </extent>
              </MD_DataIdentification>
            </identificationInfo>
          </MD_Metadata>
        XML
      end

      it 'states the box in an extent of its own, leaving the temporal one as it was' do
        extents = iso19139_ng.xpath('//gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent', namespaces)
        expect(extents.map { |extent| extent.element_children.map(&:name) })
          .to eq [%w[description temporalElement], %w[geographicElement]]
      end
    end

    context 'when the ArcGIS metadata had no extent to copy' do
      let(:source) do
        <<~XML
          <MD_Metadata xmlns="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco">
            <identificationInfo>
              <MD_DataIdentification>
                <citation/>
                <supplementalInformation><gco:CharacterString>Notes</gco:CharacterString></supplementalInformation>
              </MD_DataIdentification>
            </identificationInfo>
          </MD_Metadata>
        XML
      end

      it 'adds an extent ahead of the supplemental information' do
        identification = iso19139_ng.at_xpath('//gmd:MD_DataIdentification', namespaces)
        expect(identification.element_children.map(&:name)).to eq %w[citation extent supplementalInformation]
        expect(described_class.read(iso19139_ng)).to eq bounding_box
      end

      it 'puts the new elements in the ISO 19139 namespaces' do
        expect(boxes.first.namespace.href).to eq namespaces['gmd']
        expect(boxes.first.at_xpath('gmd:westBoundLongitude/gco:Decimal', namespaces)).to be_present
      end
    end
  end

  describe '.read' do
    it 'raises unless the record states exactly one box' do
      expect { described_class.read(Nokogiri::XML(File.read(File.join(fixture_dir, 'pv886qw6092-iso19139.xml')))) }
        .to raise_error(/states 2 geographic bounding boxes/)
    end
  end
end
