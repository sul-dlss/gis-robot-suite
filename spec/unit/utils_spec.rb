# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'utilities' do
  it 'can type vectors' do
    expect(GisRobotSuite).to be_vector('application/x-esri-shapefile')
    expect(GisRobotSuite).to be_vector('application/x-esri-shapefile; format=Shapefile')
  end

  it 'can type rasters' do
    expect(GisRobotSuite).to be_raster('image/tiff')
    expect(GisRobotSuite).to be_raster('image/tiff; format=GeoTIFF')
    expect(GisRobotSuite).to be_raster('application/x-ogc-aig')
  end

  it 'can handle bogus types' do
    expect(GisRobotSuite).not_to be_vector('image/tiff')
    expect(GisRobotSuite).not_to be_vector('application/unknown')
    expect(GisRobotSuite).not_to be_raster('application/x-esri-shapefile')
    expect(GisRobotSuite).not_to be_raster('application/unknown')
  end

  describe '.determine_rights' do
    subject { GisRobotSuite.determine_rights(druid) }

    let(:object_client) do
      instance_double(Dor::Services::Client::Object, find: cocina_model)
    end
    let(:druid) { 'fx392st8577' }
    let(:cocina_model) do
      Cocina::Models.build({
                             'externalIdentifier' => 'druid:fx392st8577',
                             'label' => 'GIS object',
                             'version' => 1,
                             'type' => Cocina::Models::ObjectType.object,
                             'description' => {
                               'title' => [{ 'value' => 'GIS object' }],
                               'purl' => 'https://purl.stanford.edu/fx392st8577'
                             },
                             'access' => {
                               'view' => access,
                               'download' => access
                             },
                             'structural' => {},
                             identification: { sourceId: 'sul:1234' },
                             'administrative' => {
                               'hasAdminPolicy' => 'druid:xx999xx9999'
                             }
                           })
    end

    before do
      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    end

    context 'when public' do
      let(:access) { 'world' }

      it { is_expected.to be 'Public' }
    end

    context 'when restricted' do
      let(:access) { 'stanford' }

      it { is_expected.to be 'Restricted' }
    end
  end
end
