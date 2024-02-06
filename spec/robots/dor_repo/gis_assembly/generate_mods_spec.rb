# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::GenerateMods do
  describe '.perform' do
    subject(:perform) { test_perform(robot, druid) }

    let(:robot) { described_class.new }

    let(:object_client) do
      instance_double(Dor::Services::Client::Object, update: nil, find: object)
    end

    let(:object) { build(:dro, id: druid).new(geographic: { iso19139: geographic_xml }) }
    let(:geographic_xml) { read_fixture('bh432xr2264-iso19139.xml') }

    before do
      allow(Settings.geohydra).to receive(:stage).and_return('spec/fixtures/stage')
      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
      allow(IO).to receive(:popen).and_return(nil)
    end

    context 'when a raster (GeoTIFF)' do
      let(:druid) { 'druid:bh432xr2264' }

      # rubocop:disable Layout/LineLength
      let(:description_props) do
        { title: [{ value: 'North Atlantic Ocean, Arquipélago dos Açores (Raster Image)' }],
          purl: 'https://purl.stanford.edu/bh432xr2264',
          note: [{ value: 'This layer is a digital raster graphic (DRG) of a scanned nautical chart titled: Arquipelago dos Acores the U.S. National Imagery and Mapping Agency, (NIMA). (Oct 2001, 7Th ed.).Covers Arquipelago dos Acores. This layer is part of a selection of digitally scanned and georeferenced maps from The Branner Library Map Collection at Stanford University.',
                   displayLabel: 'Abstract',
                   valueLanguage: { code: 'eng', source: { code: 'iso639-2b' } } },
                 { value: "Historic paper maps can provide an excellent view of the changes that have occurred in the cultural and physical landscape. The wide range of information provided on these maps make them useful in the study of historic geography, and urban and rural land use change. As this map has been georeferenced, it can be used in a GIS as a source or background layer in conjunction with other GIS data.\n",
                   displayLabel: 'Purpose',
                   valueLanguage: { code: 'eng', source: { code: 'iso639-2b' } },
                   type: 'abstract' }],
          language: [{ code: 'eng', source: { code: 'iso639-2b' } }],
          contributor: [{ name: [{ value: 'Land Info (Firm)' }], type: 'organization', role: [{ source: { code: 'marcrelator' }, value: 'creator' }] },
                        { name: [{ value: 'United States. National Imagery and Mapping Agency' }],
                          type: 'organization',
                          role: [{ source: { code: 'marcrelator' }, value: 'creator' }] }],
          event: [{ contributor: [{ name: [{ value: 'Land Info (Firm)' }],
                                    role: [{ value: 'publisher',
                                             code: 'pbl',
                                             uri: 'http://id.loc.gov/vocabulary/relators/pbl',
                                             source: { code: 'marcrelator', uri: 'http://id.loc.gov/vocabulary/relators/' } }],
                                    type: 'organization' }],
                    note: [{ type: 'edition', value: '7th' }],
                    date: [{ value: '2009', encoding: { code: 'w3cdtf' }, status: 'primary', type: 'publication' }] }],
          subject: [{ source: { code: 'lcsh', uri: 'http://id.loc.gov/authorities/subjects.html' },
                      valueLanguage: { code: 'eng', source: { code: 'iso639-2b' } },
                      value: 'Nautical charts',
                      type: 'topic' },
                    { source: { code: 'lcsh', uri: 'http://id.loc.gov/authorities/subjects.html' },
                      valueLanguage: { code: 'eng', source: { code: 'iso639-2b' } },
                      value: 'Coasts',
                      type: 'topic' },
                    { source: { code: 'lcsh', uri: 'http://id.loc.gov/authorities/subjects.html' },
                      valueLanguage: { code: 'eng', source: { code: 'iso639-2b' } },
                      value: 'Harbors',
                      type: 'topic' },
                    { source: { code: 'lcsh', uri: 'http://id.loc.gov/authorities/subjects.html' },
                      valueLanguage: { code: 'eng', source: { code: 'iso639-2b' } },
                      value: 'Maps',
                      type: 'topic' },
                    { valueLanguage: { code: 'eng', source: { code: 'iso639-2b' } }, value: 'Azores', type: 'place' },
                    { encoding: { code: 'w3cdtf' }, value: '2001', type: 'time' },
                    { source: { code: 'ISO19115TopicCategory', uri: 'http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_TopicCategoryCode' },
                      uri: 'imageryBaseMapsEarthCover',
                      value: 'Imagery and Base Maps',
                      type: 'topic' },
                    { value: 'W 32°20ʹ2ʺ--W 23°50ʹ1ʺ/N 40°30ʹ2ʺ--N 36°2ʺ', type: 'map coordinates' }],
          form: [{ type: 'genre', value: 'Geospatial data', uri: 'http://id.loc.gov/authorities/genreForms/gf2011026297', source: { code: 'lcgft' } },
                 { type: 'genre', value: 'cartographic dataset', uri: 'http://rdvocab.info/termList/RDAContentType/1001', source: { code: 'rdacontent' } },
                 { value: 'cartographic', type: 'resource type', source: { value: 'MODS resource types' } },
                 { value: 'software, multimedia', type: 'resource type', source: { value: 'MODS resource types' } },
                 { value: 'GeoTIFF', type: 'form' },
                 { value: 'born digital', type: 'digital origin', source: { value: 'MODS digital origin terms' } },
                 { value: '1:750000', type: 'map scale' },
                 { value: 'Custom projection', type: 'map projection' }],
          adminMetadata: { language: [{ code: 'eng', source: { code: 'iso639-2b' } }],
                           contributor: [{ name: [{ value: 'Stanford' }] }],
                           note: [{ type: 'record origin', value: 'This record was translated from ISO 19139 to MODS v.3 using an xsl transformation.' }],
                           identifier: [{ value: 'edu.stanford.purl:dj322nc8936' }] },
          relatedResource: [{ purl: 'https://purl.stanford.edu/dj322nc8936' }],
          geographic: [{ form: [{ value: 'image/tiff', type: 'media type', source: { value: 'IANA media type terms' } },
                                { value: 'GeoTIFF', type: 'data format' },
                                { value: 'Dataset#Raster', type: 'type' }],
                         subject: [{ structuredValue: [{ value: '-32.333876', type: 'west' },
                                                       { value: '36.000509', type: 'south' },
                                                       { value: '-23.833706', type: 'east' },
                                                       { value: '40.500427', type: 'north' }],
                                     type: 'bounding box coordinates',
                                     encoding: { value: 'decimal' },
                                     standard: { code: 'EPSG:4326' } },
                                   { value: 'Azores', type: 'coverage', valueLanguage: { code: 'eng' } }] }],
          access: { note: [{ value: 'All data is the copyrighted property of LAND INFO Worldwide Mapping, LLC and / or its suppliers. Land Info grants customer unlimited license for internal academic use of data and license to distribute data on an isolated non-commercial basis, or as Derived Works. Derived works that include the source data must be merged with other value-added data in such a way that the derived work can’t be converted back to the original source data format.  Other Derived Works that don’t include the source data (vector extraction, classification etc.) have no restrictions on use and distribution. An unlimited license is granted for media use, provided that the following citation is used:  "map data courtesy www.landinfo.com."',
                             type: 'use and reproduction' }] } }
      end
      # rubocop:enable Layout/LineLength

      it 'generates cocina descriptive metadata' do
        perform
        expect(object_client).to have_received(:update).with(params: object.new(description: description_props))
      end
    end

    context 'when a shapefile' do
      let(:druid) { 'druid:mx245jd3310' }
      let(:geographic_xml) { read_fixture('mx245jd3310-iso19139.xml') }

      # rubocop:disable Layout/LineLength
      let(:description_props) do
        { title: [{ value: 'Road Bridge Districts, Riverside County California, 2019' }],
          purl: 'https://purl.stanford.edu/mx245jd3310',
          note: [{ value: "This data set of polygon features represents Riverside County's Road and Bridge Benefit Districts. There are 4 Road and Bridge Benefit Districts within the county. Fees are assessed on new development projects to provide funding for road and bridge improvements within each district. Last updated: 9/9/2019.",
                   displayLabel: 'Abstract',
                   valueLanguage: { code: 'eng', source: { code: 'iso639-2b' } } },
                 { value: 'CREDIT', displayLabel: 'Preferred citation', valueLanguage: { code: 'eng', source: { code: 'iso639-2b' } } },
                 { value: 'These data are made available as a public service. The data is for reference purposes only, and the originator(s) make no representatives, warranties, or guarantees as to the accuracy of the data. Information found here should not be used for making financial or any other commitments. In no way shall the originator(s) become liable to users of these data, or any other party, for any loss or direct, indirect, special, incidental or consequential damages, including but not limited to time, money or goodwill, arising from the use or modification of the data. This data is in the public domain.',
                   displayLabel: 'Use limitation' }],
          language: [{ code: 'eng', source: { code: 'iso639-2b' } }],
          contributor: [{ name: [{ value: 'Riverside County (Calif.). Geographic Information Services' }],
                          type: 'organization',
                          role: [{ source: { code: 'marcrelator' }, value: 'creator' }] }],
          event: [{ location: [{ value: 'US' }],
                    contributor: [{ name: [{ value: 'Riverside County (Calif.). Geographic Information Services' }],
                                    role: [{ value: 'publisher',
                                             code: 'pbl',
                                             uri: 'http://id.loc.gov/vocabulary/relators/pbl',
                                             source: { code: 'marcrelator', uri: 'http://id.loc.gov/vocabulary/relators/' } }],
                                    type: 'organization' }],
                    date: [{ value: '2019', encoding: { code: 'w3cdtf' }, status: 'primary', type: 'publication' }] }],
          subject: [{ source: { code: 'lcsh', uri: 'http://id.loc.gov/authorities/subjects.html' },
                      valueLanguage: { code: 'eng', source: { code: 'iso639-2b' } },
                      value: 'Roads',
                      type: 'topic' },
                    { source: { code: 'lcsh', uri: 'http://id.loc.gov/authorities/subjects.html' },
                      valueLanguage: { code: 'eng', source: { code: 'iso639-2b' } },
                      value: 'Bridges',
                      type: 'topic' },
                    { valueLanguage: { code: 'eng', source: { code: 'iso639-2b' } }, value: 'Riverside County (Calif.)', type: 'place' },
                    { encoding: { code: 'w3cdtf' }, value: '2019', type: 'time' },
                    { source: { code: 'ISO19115TopicCategory', uri: 'http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_TopicCategoryCode' },
                      uri: 'transportation',
                      value: 'Transportation',
                      type: 'topic' },
                    { value: 'W 117°36ʹ46ʺ--W 117°3ʹ56ʺ/N 34°2ʹ15ʺ--N 33°28ʹ22ʺ', type: 'map coordinates' }],
          form: [{ type: 'genre', value: 'Geospatial data', uri: 'http://id.loc.gov/authorities/genreForms/gf2011026297', source: { code: 'lcgft' } },
                 { type: 'genre', value: 'cartographic dataset', uri: 'http://rdvocab.info/termList/RDAContentType/1001', source: { code: 'rdacontent' } },
                 { value: 'cartographic', type: 'resource type', source: { value: 'MODS resource types' } },
                 { value: 'software, multimedia', type: 'resource type', source: { value: 'MODS resource types' } },
                 { value: 'Shapefile', type: 'form' },
                 { value: '0.07', type: 'extent' },
                 { value: 'born digital', type: 'digital origin', source: { value: 'MODS digital origin terms' } },
                 { value: 'Scale not given.', type: 'map scale' },
                 { value: 'Custom projection', type: 'map projection' }],
          adminMetadata: { language: [{ code: 'eng', source: { code: 'iso639-2b' } }],
                           contributor: [{ name: [{ value: 'Stanford' }] }],
                           note: [{ type: 'record origin', value: 'This record was translated from ISO 19139 to MODS v.3 using an xsl transformation.' }],
                           identifier: [{ value: 'edu.stanford.purl:fh516dn9215' }] },
          relatedResource: [{ purl: 'https://purl.stanford.edu/fh516dn9215' }],
          geographic: [{ form: [{ value: 'application/x-esri-shapefile', type: 'media type', source: { value: 'IANA media type terms' } },
                                { value: 'Shapefile', type: 'data format' },
                                { value: 'Dataset#Polygon', type: 'type' }],
                         subject: [{ structuredValue: [{ value: '-117.612825', type: 'west' },
                                                       { value: '33.472658', type: 'south' },
                                                       { value: '-117.065506', type: 'east' },
                                                       { value: '34.03759', type: 'north' }],
                                     type: 'bounding box coordinates',
                                     encoding: { value: 'decimal' },
                                     standard: { code: ':0' } },
                                   { value: 'Riverside County (Calif.)', type: 'coverage', valueLanguage: { code: 'eng' } }] }] }
      end
      # rubocop:enable Layout/LineLength

      it 'generates cocina descriptive metadata' do
        perform
        expect(object_client).to have_received(:update).with(params: object.new(description: description_props))
      end
    end

    context 'when a GeoJSON file' do
      let(:druid) { 'druid:vx812cc5548' }
      let(:geographic_xml) { read_fixture('CLOWNS_OF_AMERICA-iso19139.xml') }

      # rubocop:disable Layout/LineLength
      let(:description_props) do
        { title: [{ value: 'Clowns of America, International Membership Point GeoJSON (anonymized)' }],
          purl: 'https://purl.stanford.edu/vx812cc5548',
          note: [{ value: "This point GeoJSON was created from the Clowns of America International Membership Database (anonymized) obtained in 2007 from Clowns of America, International, for use in teaching. It was created by geocoding the ZipCode field of the original table, using OpenRefine and the Geonames.org PostalCodes API. Attributes include those from the original data table (\"City\", \"ZipCode\", \"Clown_Name\", and \"Country\"), as well attributes added during the geocoding process (\"admname1\",\"adm1\",\"adm2\",\"placname\",\"longitude\",\"latitude\") and an attribute \"Clown-Na_1\" which represents the values in the \"Clown_Name\" attribute field after a \"Cluster and Edit\" operation, performed in OpenRefine to collapse values so that \"Co Co\" or \"Co-Co\" both are clustered and edited to become \"CoCo\" for use in name frequency analysis. This layer is intended to be used for teaching and instruction at Stanford\"s Geospatial Center. ",
                   displayLabel: 'Abstract',
                   valueLanguage: { code: 'eng', source: { code: 'iso639-2b' } } }],
          language: [{ code: 'eng', source: { code: 'iso639-2b' } }],
          contributor: [{ name: [{ value: 'Maples, Stacey D.' }],
                          type: 'person',
                          role: [{ source: { code: 'marcrelator' }, value: 'creator' }] }],
          event: [{ location: [{ value: 'US' }],
                    date: [{ value: '2007', encoding: { code: 'w3cdtf' }, status: 'primary', type: 'publication' }] }],
          subject: [{ source: { code: 'lcsh', uri: 'http://id.loc.gov/authorities/subjects.html' },
                      valueLanguage: { code: 'eng', source: { code: 'iso639-2b' } },
                      value: 'Clowns',
                      type: 'topic' },
                    { valueLanguage: { code: 'eng', source: { code: 'iso639-2b' } },
                      value: 'United States',
                      type: 'place' },
                    { encoding: { code: 'w3cdtf' }, value: '2007', type: 'time' },
                    { source: { code: 'ISO19115TopicCategory', uri: 'http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_TopicCategoryCode' },
                      uri: 'location',
                      value: 'Location',
                      type: 'topic' },
                    { value: 'W 158°1ʹ3ʺ--W 65°35ʹ41ʺ/N 64°51ʹ16ʺ--N 18°7ʺ', type: 'map coordinates' }],
          form: [{ type: 'genre', value: 'Geospatial data', uri: 'http://id.loc.gov/authorities/genreForms/gf2011026297', source: { code: 'lcgft' } },
                 { type: 'genre', value: 'cartographic dataset', uri: 'http://rdvocab.info/termList/RDAContentType/1001', source: { code: 'rdacontent' } },
                 { value: 'cartographic', type: 'resource type', source: { value: 'MODS resource types' } },
                 { value: 'software, multimedia', type: 'resource type', source: { value: 'MODS resource types' } },
                 { value: 'GeoJSON', type: 'form' },
                 { value: 'born digital', type: 'digital origin', source: { value: 'MODS digital origin terms' } },
                 { value: 'Scale not given.', type: 'map scale' },
                 { value: 'Custom projection', type: 'map projection' }],
          adminMetadata: { language: [{ code: 'eng', source: { code: 'iso639-2b' } }],
                           contributor: [{ name: [{ value: 'Stanford' }] }],
                           note: [{ type: 'record origin', value: 'This record was translated from ISO 19139 to MODS v.3 using an xsl transformation.' }],
                           identifier: [{ value: 'edu.stanford.purl:vx812cc5548' }] },
          geographic: [{ form: [{ value: 'application/x-unknown', type: 'media type', source: { value: 'IANA media type terms' } },
                                { value: 'Dataset#Polygon', type: 'type' }],
                         subject: [{ structuredValue: [{ value: '-158.017379', type: 'west' },
                                                       { value: '18.001995', type: 'south' },
                                                       { value: '-65.594769', type: 'east' },
                                                       { value: '64.85437', type: 'north' }],
                                     type: 'bounding box coordinates',
                                     encoding: { value: 'decimal' },
                                     standard: { code: 'EPSG:4326' } },
                                   { value: 'United States', type: 'coverage', valueLanguage: { code: 'eng' } }] }],
          access: {
            note: [{
              value: "User agrees that, where applicable, content will not be used to identify or to otherwise infringe the privacy or confidentiality rights of individuals. Content distributed via the Stanford Digital Repository may be subject to additional license and use restrictions applied by the depositor.",
              type: "use and reproduction"
            }]
          }}
      end
      # rubocop:enable Layout/LineLength

      it 'generates cocina descriptive metadata' do
        perform
        expect(object_client).to have_received(:update).with(params: object.new(description: description_props))
      end
    end
  end

  describe '.dd2ddmmss_abs' do
    it 'converts DD to DDMMSS' do
      expect(described_class.new.send(:dd2ddmmss_abs, '-109.758319')).to eq('109°45ʹ30ʺ')
      expect(described_class.new.send(:dd2ddmmss_abs, '48.999336')).to eq('48°59ʹ58ʺ')
    end
  end

  describe '.to_coordinates_ddmmss' do
    it 'converts MARC to DDMMSS' do
      expect(described_class.new.send(:to_coordinates_ddmmss, '-180 -- 180/90 -- -90')).to eq('W 180°--E 180°/N 90°--S 90°')
      expect(described_class.new.send(:to_coordinates_ddmmss, '-109.758319 -- -88.990844/48.999336 -- 29.423028')).to eq('W 109°45ʹ30ʺ--W 88°59ʹ27ʺ/N 48°59ʹ58ʺ--N 29°25ʹ23ʺ')
    end

    it 'handles bad arguments' do
      expect { described_class.new.send(:to_coordinates_ddmmss, '-185 -- 185/95 -- -95') }.to raise_error(ArgumentError)
    end
  end
end
