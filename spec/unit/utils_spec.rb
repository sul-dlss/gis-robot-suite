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
    subject { GisRobotSuite.determine_rights(cocina_object) }

    let(:cocina_object) { build(:dro).new(access: { view: access, download: access }) }

    context 'when public' do
      let(:access) { 'world' }

      it { is_expected.to eq 'public' }
    end

    context 'when restricted' do
      let(:access) { 'stanford' }

      it { is_expected.to eq 'restricted' }
    end
  end
end
