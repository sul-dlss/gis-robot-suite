# encoding: UTF-8

require 'spec_helper'

RSpec.describe GisRobotSuite::Gazetteer do
  it 'can boot' do
    expect(subject.is_a? Object).to be_truthy
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

  it 'can translate to LC authority namespace' do
    expect(subject.find_loc_authority('Accra (Ghana)')).to eq 'lcnaf'
    expect(subject.find_loc_authority('Andaman Islands (India)')).to eq 'lcsh'
    expect(subject.find_loc_authority('Moga (India : District)')).to eq 'lcnaf'
    expect(subject.find_loc_authority('Attur (India)')).to be_nil
  end

  it 'can translate to LC placename URIs' do
    expect(subject.find_loc_uri('Accra (Ghana)')).to eq 'http://id.loc.gov/authorities/names/n79059515'
    expect(subject.find_loc_uri('Andaman Islands (India)')).to eq 'http://id.loc.gov/authorities/subjects/sh96007926'
    expect(subject.find_loc_uri('Moga (India : District)')).to eq 'http://id.loc.gov/authorities/names/no2003104540'
  end

  it 'cannot translate missing LC placename URIs' do
    expect(subject.find_loc_uri('Albion River Watershed (Calif.)')).to be_nil
    expect(subject.find_loc_uri('Dichpalli (India)')).to be_nil
  end

  it 'can translate to LC placename' do
    expect(subject.find_loc_keyword('Accra (Ghana)')).to eq 'Accra (Ghana)'
    expect(subject.find_loc_keyword('Andaman Islands (India)')).to eq 'Andaman Islands (India)'
    expect(subject.find_loc_keyword('Moga (India : District)')).to eq 'Moga (India : District)'
  end

  it 'can handle UTF-8' do
    expect(subject.find_placename('Melli Bāzār (India)')).to eq 'Melli Bāzār'
  end

  it 'should never have a LC mapping but not a GeoNames mapping' do
    subject.each do |k|
      expect(subject.find_loc_uri(k) && !subject.find_placename_uri(k)).to be_falsey
    end
  end

  it 'should never load bogus placenames' do
    expect(subject.blank? 'BogusBogusBogus').to be_falsey
  end
end
