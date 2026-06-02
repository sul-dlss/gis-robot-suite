# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::Gazetteer do
  it 'can translate to GeoNames placename URIs' do
    expect(described_class.new.find_placename_uri('Accra (Ghana)')).to eq 'http://sws.geonames.org/2306104/'
    expect(described_class.new.find_placename_uri('Dichpalli (India)')).to eq 'http://sws.geonames.org/1272645/'
  end

  it 'cannot translate missing GeoNames URIs' do
    expect(described_class.new.find_placename_uri('Albion River Watershed (Calif.)')).to be_nil
  end
end
