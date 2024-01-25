# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::Gazetteer do
  it 'can boot' do
    expect(subject).to be_a(Object)
  end

  it 'can translate to GeoNames IDs' do
    expect(subject.find_id('Accra (Ghana)')).to eq 2306104
    expect(subject.find_id('Dichpalli (India)')).to eq 1272645
  end

  it 'can translate from GeoNames IDs' do
    expect(subject.find_keyword_by_id(2306104)).to eq 'Accra (Ghana)'
    expect(subject.find_keyword_by_id(1272645)).to eq 'Dichpalli (India)'
  end

  it 'can translate to GeoNames placename URIs' do
    expect(subject.find_placename_uri('Accra (Ghana)')).to eq 'http://sws.geonames.org/2306104/'
    expect(subject.find_placename_uri('Dichpalli (India)')).to eq 'http://sws.geonames.org/1272645/'
  end

  it 'cannot translate missing GeoNames URIs' do
    expect(subject.find_placename_uri('Albion River Watershed (Calif.)')).to be_nil
  end

  it 'can translate to GeoNames placenames' do
    expect(subject.find_placename('Medan (Indonesia)')).to eq 'Medan'
  end

  it 'can handle UTF-8' do
    expect(subject.find_placename('Melli Bāzār (India)')).to eq 'Melli Bāzār'
  end

  it 'never loads bogus placenames' do
    expect(subject).not_to be_blank('BogusBogusBogus')
  end
end
