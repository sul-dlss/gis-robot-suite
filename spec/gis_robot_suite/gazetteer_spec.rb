# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::Gazetteer do
  it 'returns properties for a Library of Congress name authority' do
    expect(described_class.new.find_placename('Accra (Ghana)')).to eq(
      uri: 'http://id.loc.gov/authorities/names/n79059515',
      source: {
        code: 'naf',
        uri: 'http://id.loc.gov/authorities/names/'
      }
    )
  end

  it 'returns properties for a Library of Congress subject authority' do
    expect(described_class.new.find_placename('Africa')).to eq(
      uri: 'http://id.loc.gov/authorities/subjects/sh85001531',
      source: {
        code: 'lcsh',
        uri: 'http://id.loc.gov/authorities/subjects/'
      }
    )
  end

  it 'cannot translate missing Library of Congress URIs' do
    expect(described_class.new.find_placename('Dichpalli (India)')).to be_nil
    expect(described_class.new.find_placename('Albion River Watershed (Calif.)')).to be_nil
  end

  it 'streams the CSV and caches only the most recent lookup' do
    allow(CSV).to receive(:foreach).and_call_original
    gazetteer = described_class.new

    expect(gazetteer.find_placename('Dichpalli (India)')).to be_nil
    expect(gazetteer.blank?('Dichpalli (India)')).to be true
    expect(CSV).to have_received(:foreach).once
  end
end
