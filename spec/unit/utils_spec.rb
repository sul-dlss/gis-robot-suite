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

end
