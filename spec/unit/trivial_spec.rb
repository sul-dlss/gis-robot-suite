# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'booting' do
  it 'can boot gisAssembly' do
    expect(Robots::DorRepo::GisAssembly.is_a? Module).to be_truthy
  end

  it 'can boot gisDelivery' do
    expect(Robots::DorRepo::GisDelivery.is_a? Module).to be_truthy
  end
end
