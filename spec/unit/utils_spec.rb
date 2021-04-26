# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'utilities' do
  it 'can type vectors' do
    expect(GisRobotSuite.vector?('application/x-esri-shapefile')).to be_truthy
    expect(GisRobotSuite.vector?('application/x-esri-shapefile; format=Shapefile')).to be_truthy
  end

  it 'can type rasters' do
    expect(GisRobotSuite.raster?('image/tiff')).to be_truthy
    expect(GisRobotSuite.raster?('image/tiff; format=GeoTIFF')).to be_truthy
    expect(GisRobotSuite.raster?('application/x-ogc-aig')).to be_truthy
  end

  it 'can handle bogus types' do
    expect(GisRobotSuite.vector?('image/tiff')).to be_falsey
    expect(GisRobotSuite.vector?('application/unknown')).to be_falsey
    expect(GisRobotSuite.raster?('application/x-esri-shapefile')).to be_falsey
    expect(GisRobotSuite.raster?('application/unknown')).to be_falsey
  end

  describe '.determine_rights' do
    subject { GisRobotSuite.determine_rights(druid) }

    let(:object_client) do
      instance_double(Dor::Services::Client::Object, find: cocina_model)
    end
    let(:druid) { 'fx392st8577' }
    let(:cocina_model) do
      Cocina::Models.build(
        'externalIdentifier' => 'druid:fx392st8577',
        'label' => 'GIS object',
        'version' => 1,
        'type' => Cocina::Models::Vocab.object,
        'access' => {
          'access' => access,
          'download' => access
        },
        'administrative' => {
          'hasAdminPolicy' => 'druid:xx999xx9999'
        }
      )
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
