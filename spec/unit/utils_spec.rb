require 'spec_helper'

describe 'utilities' do
  
  it 'can type vectors' do
    expect(GisRobotSuite.determine_mimetype(:vector)).to eq('application/x-esri-shapefile')
  end
  
  it 'can type rasters' do
    expect(GisRobotSuite.determine_mimetype(:raster)).to eq('image/tiff')
  end

  it 'can handle bogus types' do
    expect {GisRobotSuite.determine_mimetype(:bogus)}.to raise_error(ArgumentError)
  end
  
end