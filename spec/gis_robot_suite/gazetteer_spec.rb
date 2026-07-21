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
end
