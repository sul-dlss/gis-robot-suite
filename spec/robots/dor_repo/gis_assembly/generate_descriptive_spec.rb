# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::GenerateDescriptive do
  describe '.perform' do
    subject(:perform) { test_perform(robot, druid) }

    let(:robot) { described_class.new }
    let(:object_client) do
      instance_double(Dor::Services::Client::Object, update: nil, find: cocina_object)
    end
    let(:cocina_object) { build(:dro, id: druid) }
    let(:staging_dir) { File.join(fixture_dir, 'stage', bare_druid, 'temp') }

    # Remove ISO19139.xml to restore temp dir to clean state at beginning of gisAssembly workflow
    def cleanup
      Dir.glob("#{staging_dir}/*-iso19139.xml").each { |f| File.delete(f) }
    end

    # Copy ISO19139.xml into temp dir for tests
    def copy_fixture(bare_druid)
      iso19139_fixture = File.join(fixture_dir, "#{bare_druid}-iso19139.xml")
      FileUtils.cp(iso19139_fixture, staging_dir)
    end

    before do
      copy_fixture(bare_druid)
      allow(Settings.geohydra).to receive(:stage).and_return('spec/fixtures/stage')
      allow(Settings.purl).to receive(:url).and_return('https://purl.stanford.edu')
      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
      # allow(IO).to receive(:popen).and_return(nil)
    end

    after { cleanup }

    context 'when a raster (GeoTIFF)' do
      let(:druid) { 'druid:bh432xr2264' }
      let(:bare_druid) { 'bh432xr2264' }

      # rubocop:disable Layout/LineLength
      let(:description_props) do
        { title: [{ value: 'North Atlantic Ocean, Arquipélago dos Açores (Raster Image)' }, { value: 'North Atlantic Ocean', type: 'alternative', displayLabel: 'Alternative title' }],
          contributor: [{ name: [{ value: 'Land Info (Firm)' }], type: 'organization', role: [{ source: { code: 'marcrelator' }, value: 'creator' }] },
                        { name: [{ value: 'United States. National Imagery and Mapping Agency' }],
                          type: 'organization',
                          role: [{ source: { code: 'marcrelator' }, value: 'creator' }] }],
          purl: 'https://purl.stanford.edu/bh432xr2264',
          note: [{ value: 'This layer is a digital raster graphic (DRG) of a scanned nautical chart titled: Arquipelago dos Acores the U.S. National Imagery and Mapping Agency, (NIMA). (Oct 2001, 7Th ed.).Covers Arquipelago dos Acores. This layer is part of a selection of digitally scanned and georeferenced maps from The Branner Library Map Collection at Stanford University.',
                   displayLabel: 'Abstract',
                   type: 'abstract' },
                 { value: 'Historic paper maps can provide an excellent view of the changes that have occurred in the cultural and physical landscape. The wide range of information provided on these maps make them useful in the study of historic geography, and urban and rural land use change. As this map has been georeferenced, it can be used in a GIS as a source or background layer in conjunction with other GIS data.',
                   displayLabel: 'Purpose',
                   type: 'other' },
                 { value: 'Some supplemental information about the data.',
                   displayLabel: 'Supplemental information',
                   type: 'other' },
                 { value: 'Schultz, Kenneth A. "Mapping Interstate Territorial Conflict: A New Data Set and Applications." The Journal of Conflict Resolution (2015). Available at: http://dx.doi.org/10.1177/0022002715620470',
                   displayLabel: 'Related publication',
                   type: 'citation/reference' }],
          language: [{ code: 'eng', source: { code: 'ISO639-2' } }],
          event: [{ contributor: [{ name: [{ value: 'Land Info (Firm)' }],
                                    role: [{ value: 'publisher',
                                             code: 'pbl',
                                             uri: 'http://id.loc.gov/vocabulary/relators/pbl',
                                             source: { code: 'marcrelator', uri: 'http://id.loc.gov/vocabulary/relators/' } }],
                                    type: 'organization' },
                                  { name: [{ value: 'Sea Info (Firm)' }],
                                    role: [{ value: 'publisher',
                                             code: 'pbl',
                                             uri: 'http://id.loc.gov/vocabulary/relators/pbl',
                                             source: { code: 'marcrelator', uri: 'http://id.loc.gov/vocabulary/relators/' } }],
                                    type: 'organization' },
                                  { name: [{ value: 'Hubing, Nick' }],
                                    role: [{ value: 'publisher',
                                             code: 'pbl',
                                             uri: 'http://id.loc.gov/vocabulary/relators/pbl',
                                             source: { code: 'marcrelator', uri: 'http://id.loc.gov/vocabulary/relators/' } }],
                                    type: 'person' }],
                    note: [{ type: 'edition', value: '7th' }],
                    date: [{ value: '2009', encoding: { code: 'w3cdtf' }, status: 'primary', type: 'publication' },
                           { structuredValue: [{ value: '2000', type: 'start' },
                                               { value: '2003', type: 'end' }],
                             encoding: { code: 'w3cdtf' },
                             type: 'validity' }] }],
          subject: [{ source: { code: 'geonames', uri: 'http://www.geonames.org/ontology#' },
                      value: 'Azores',
                      type: 'place' },
                    { source: { code: 'lcsh', uri: 'http://id.loc.gov/authorities/subjects.html' },
                      value: 'Nautical charts',
                      type: 'topic' },
                    { source: { code: 'lcsh', uri: 'http://id.loc.gov/authorities/subjects.html' },
                      value: 'Coasts',
                      type: 'topic' },
                    { source: { code: 'lcsh', uri: 'http://id.loc.gov/authorities/subjects.html' },
                      value: 'Harbors',
                      type: 'topic' },
                    { source: { code: 'lcsh', uri: 'http://id.loc.gov/authorities/subjects.html' },
                      value: 'Maps',
                      type: 'topic' },
                    { source: { code: 'ISO19115TopicCategory', uri: 'http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_TopicCategoryCode' },
                      uri: 'imageryBaseMapsEarthCover',
                      value: 'Imagery and Base Maps',
                      type: 'topic' },
                    { encoding: { code: 'w3cdtf' }, value: '2001', type: 'time' },
                    { value: 'W 32°20ʹ2ʺ--W 23°50ʹ1ʺ/N 40°30ʹ2ʺ--N 36°2ʺ', type: 'map coordinates' }],
          form: [{ value: 'Geospatial data', type: 'genre', uri: 'http://id.loc.gov/authorities/genreForms/gf2011026297', source: { code: 'lcgft' } },
                 { value: 'cartographic dataset', type: 'genre', uri: 'http://rdvocab.info/termList/RDAContentType/1001', source: { code: 'rdacontent' } },
                 { value: 'cartographic', type: 'resource type', source: { value: 'MODS resource types' } },
                 { value: 'software, multimedia', type: 'resource type', source: { value: 'MODS resource types' } },
                 { value: 'born digital', type: 'digital origin', source: { value: 'MODS digital origin terms' } },
                 { value: 'Dataset', type: 'genre', source: { value: 'local' } },
                 { value: 'GeoTIFF', type: 'form' },
                 { value: 'EPSG::4326', type: 'map projection' }],
          adminMetadata: { language: [{ code: 'eng', source: { code: 'ISO639-2' } }],
                           contributor: [{ name: [{ value: 'Stanford' }] }],
                           identifier: [{ value: 'edu.stanford.purl:dj322nc8936' }],
                           event: [{ type: 'creation', date: [{ value: '2024-01-16', encoding: { code: 'w3cdtf' } }] }] },
          relatedResource: [{ title: [{ value: 'North Atlantic Ocean, Arquipélago dos Açores' }],
                              type: 'has other format',
                              displayLabel: 'Scanned map',
                              purl: 'https://purl.stanford.edu/jf567jb0412' }],
          geographic: [{ form: [{ value: 'image/tiff', type: 'media type', source: { value: 'IANA media type terms' } },
                                { value: 'GeoTIFF', type: 'data format' },
                                { value: 'Dataset#Raster', type: 'type' }] }],
          access: { accessContact: [{ value: 'nick@landinfo.com', type: 'email', displayLabel: 'Contact' }] },
          identifier: [{ displayLabel: 'DOI',
                         value: 'https://doi.org/10.25740/bh432xr2264',
                         source: { code: 'doi' } }] }
      end
      # rubocop:enable Layout/LineLength

      it 'generates cocina descriptive metadata' do
        perform
        expect(object_client).to have_received(:update) do |args|
          expect(args[:params].description.to_h).to match Cocina::Models::Description.new(description_props).to_h
        end
      end
    end

    context 'when a shapefile' do
      let(:druid) { 'druid:mx245jd3310' }
      let(:bare_druid) { 'mx245jd3310' }
      let(:cocina_object) { build(:dro, id: druid).new(description: original_description) }
      let(:original_description) do
        {
          title: [
            {
              value: 'Road Bridge Districts, Riverside County California, 2019'
            }
          ],
          purl: 'https://purl.stanford.edu/mx245jd3310',
          subject: [],
          form: [
            { value: 'Shapefile', type: 'form' },
            { value: 'EPSG::4326', type: 'map projection' }
          ],
          adminMetadata: {
            event: [
              {
                type: 'creation',
                date: [{ value: '2022-06-01', encoding: { code: 'w3cdtf' } }]
              }
            ]
          }
        }
      end

      # rubocop:disable Layout/LineLength
      let(:description_props) do
        { title: [{ value: 'Road Bridge Districts, Riverside County California, 2019' }],
          purl: 'https://purl.stanford.edu/mx245jd3310',
          note: [{ value: "This data set of polygon features represents Riverside County's Road and Bridge Benefit Districts. There are 4 Road and Bridge Benefit Districts within the county. Fees are assessed on new development projects to provide funding for road and bridge improvements within each district. Last updated: 9/9/2019.",
                   displayLabel: 'Abstract',
                   type: 'abstract' }],
          language: [{ code: 'eng', source: { code: 'ISO639-2' } }],
          contributor: [{ name: [{ value: 'Riverside County (Calif.). Geographic Information Services' }],
                          type: 'organization',
                          role: [{ source: { code: 'marcrelator' }, value: 'creator' }] }],
          event: [{ contributor: [{ name: [{ value: 'Riverside County (Calif.). Geographic Information Services' }],
                                    role: [{ value: 'publisher',
                                             code: 'pbl',
                                             uri: 'http://id.loc.gov/vocabulary/relators/pbl',
                                             source: { code: 'marcrelator', uri: 'http://id.loc.gov/vocabulary/relators/' } }],
                                    type: 'organization' }],
                    date: [{ value: '2019', encoding: { code: 'w3cdtf' }, status: 'primary', type: 'publication' }] }],
          subject: [{ source: { code: 'geonames', uri: 'http://www.geonames.org/ontology#' },
                      value: 'Riverside County (Calif.)', type: 'place' },
                    { source: { code: 'lcsh', uri: 'http://id.loc.gov/authorities/subjects.html' },
                      value: 'Roads',
                      type: 'topic' },
                    { source: { code: 'lcsh', uri: 'http://id.loc.gov/authorities/subjects.html' },
                      value: 'Bridges',
                      type: 'topic' },
                    { source: { code: 'ISO19115TopicCategory', uri: 'http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_TopicCategoryCode' },
                      uri: 'transportation',
                      value: 'Transportation',
                      type: 'topic' },
                    { encoding: { code: 'w3cdtf' }, value: '2019', type: 'time' },
                    { value: 'W 117°36ʹ46ʺ--W 117°3ʹ56ʺ/N 34°2ʹ15ʺ--N 33°28ʹ22ʺ', type: 'map coordinates' }],
          form: [{ type: 'genre', value: 'Geospatial data', uri: 'http://id.loc.gov/authorities/genreForms/gf2011026297', source: { code: 'lcgft' } },
                 { type: 'genre', value: 'cartographic dataset', uri: 'http://rdvocab.info/termList/RDAContentType/1001', source: { code: 'rdacontent' } },
                 { value: 'cartographic', type: 'resource type', source: { value: 'MODS resource types' } },
                 { value: 'software, multimedia', type: 'resource type', source: { value: 'MODS resource types' } },
                 { value: 'born digital', type: 'digital origin', source: { value: 'MODS digital origin terms' } },
                 { value: 'Dataset', type: 'genre', source: { value: 'local' } },
                 { value: 'Shapefile', type: 'form' },
                 { value: 'EPSG::4326', type: 'map projection' }],
          adminMetadata: { language: [{ code: 'eng', source: { code: 'ISO639-2' } }],
                           contributor: [{ name: [{ value: 'Stanford' }] }],
                           identifier: [{ value: 'edu.stanford.purl:fh516dn9215' }],
                           event: [{ type: 'creation',
                                     date: [{ value: '2022-06-01', encoding: { code: 'w3cdtf' } }] },
                                   { type: 'modification',
                                     date: [{ value: '2024-01-16', encoding: { code: 'w3cdtf' } }] }] },
          geographic: [{ form: [{ value: 'application/x-esri-shapefile', type: 'media type', source: { value: 'IANA media type terms' } },
                                { value: 'Shapefile', type: 'data format' },
                                { value: 'Dataset#Polygon', type: 'type' }] }] }
      end
      # rubocop:enable Layout/LineLength

      it 'generates cocina descriptive metadata' do
        perform
        expect(object_client).to have_received(:update) do |args|
          expect(args[:params].description.to_h).to match Cocina::Models::Description.new(description_props).to_h
        end
      end
    end

    context 'when a GeoJSON file' do
      let(:druid) { 'druid:vx813cc5549' }
      let(:bare_druid) { 'vx813cc5549' }

      # rubocop:disable Layout/LineLength
      let(:description_props) do
        { title: [{ value: 'Clowns of America, International Membership Point GeoJSON (anonymized)' }],
          purl: 'https://purl.stanford.edu/vx813cc5549',
          note: [{ value: 'This point GeoJSON was created from the Clowns of America International Membership Database (anonymized) obtained in 2007 from Clowns of America, International, for use in teaching. It was created by geocoding the ZipCode field of the original table, using OpenRefine and the Geonames.org PostalCodes API. Attributes include those from the original data table ("City", "ZipCode", "Clown_Name", and "Country"), as well attributes added during the geocoding process ("admname1","adm1","adm2","placname","longitude","latitude") and an attribute "Clown-Na_1" which represents the values in the "Clown_Name" attribute field after a "Cluster and Edit" operation, performed in OpenRefine to collapse values so that "Co Co" or "Co-Co" both are clustered and edited to become "CoCo" for use in name frequency analysis. This layer is intended to be used for teaching and instruction at Stanford"s Geospatial Center. ',
                   displayLabel: 'Abstract', type: 'abstract' }],
          language: [{ code: 'eng', source: { code: 'ISO639-2' } }],
          contributor: [{ name: [{ value: 'Maples, Stacey D.' }],
                          type: 'person',
                          role: [{ source: { code: 'marcrelator' }, value: 'creator' }] }],
          event: [{ date: [{ value: '2007', encoding: { code: 'w3cdtf' }, status: 'primary', type: 'publication' },
                           { value: '2007', encoding: { code: 'w3cdtf' }, type: 'validity' }] }],
          subject: [{ source: { code: 'geonames', uri: 'http://www.geonames.org/ontology#' },
                      value: 'United States',
                      type: 'place' },
                    { source: { code: 'lcsh', uri: 'http://id.loc.gov/authorities/subjects.html' },
                      value: 'Clowns',
                      type: 'topic' },
                    { source: { code: 'ISO19115TopicCategory', uri: 'http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_TopicCategoryCode' },
                      uri: 'location',
                      value: 'Location',
                      type: 'topic' },
                    { encoding: { code: 'w3cdtf' }, value: '2006-2007', type: 'time' },
                    { value: 'W 158°1ʹ3ʺ--W 65°35ʹ41ʺ/N 64°51ʹ16ʺ--N 18°7ʺ', type: 'map coordinates' }],
          form: [{ type: 'genre', value: 'Geospatial data', uri: 'http://id.loc.gov/authorities/genreForms/gf2011026297', source: { code: 'lcgft' } },
                 { type: 'genre', value: 'cartographic dataset', uri: 'http://rdvocab.info/termList/RDAContentType/1001', source: { code: 'rdacontent' } },
                 { value: 'cartographic', type: 'resource type', source: { value: 'MODS resource types' } },
                 { value: 'software, multimedia', type: 'resource type', source: { value: 'MODS resource types' } },
                 { value: 'born digital', type: 'digital origin', source: { value: 'MODS digital origin terms' } },
                 { value: 'Dataset', type: 'genre', source: { value: 'local' } },
                 { value: 'GeoJSON', type: 'form' },
                 { value: 'EPSG::4326', type: 'map projection' },
                 { value: '170.784 MB', type: 'extent' }],
          adminMetadata: { language: [{ code: 'eng', source: { code: 'ISO639-2' } }],
                           contributor: [{ name: [{ value: 'Stanford' }] }],
                           identifier: [{ value: 'edu.stanford.purl:vx813cc5549' }] },
          geographic: [{ form: [{ value: 'application/geo+json', type: 'media type', source: { value: 'IANA media type terms' } },
                                { value: 'GeoJSON', type: 'data format' },
                                { value: 'Dataset#Point', type: 'type' }] }] }
      end
      # rubocop:enable Layout/LineLength

      it 'generates cocina descriptive metadata' do
        perform

        expect(object_client).to have_received(:update) do |args|
          expect(args[:params].description.to_h).to match Cocina::Models::Description.new(description_props).to_h
        end
      end
    end
  end
end
