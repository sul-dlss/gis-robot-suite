# frozen_string_literal: true

require 'spec_helper'

describe 'utilities' do

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
    before do
      allow(Dor).to receive(:find).and_return(dor_item)
    end

    context 'when public' do
      let(:dor_item) do
        Dor::Item.new(pid: druid).tap do |item|
          item.rightsMetadata.content = read_fixture('workspace/fx/392/st/8577/fx392st8577/metadata/rightsMetadata.xml')
        end
      end

      let(:druid) { 'fx392st8577' }

      it do
        expect(GisRobotSuite.determine_rights(druid)).to be 'Public'
      end
    end

    context 'when restricted' do
      let(:dor_item) do
        Dor::Item.new(pid: druid).tap do |item|
          item.rightsMetadata.content = read_fixture('workspace/bb/338/jh/0716/bb338jh0716/metadata/rightsMetadata.xml')
        end
      end

      let(:druid) { 'fx392st8577' }

      it do
        expect(GisRobotSuite.determine_rights(druid)).to be 'Restricted'
      end
    end
  end
end
