require 'spec_helper'

describe 'booting' do
  it 'can boot' do
    expect {
      require_relative '../../config/boot'
    }.not_to raise_error
  end

  it 'can boot gisAssembly' do
    expect(Robots::DorRepo::GisAssembly.is_a? Module).to be_truthy
  end

  it 'can boot gisDelivery' do
    expect(Robots::DorRepo::GisDelivery.is_a? Module).to be_truthy
  end

  it 'can boot gisDiscovery' do
    expect(Robots::DorRepo::GisDiscovery.is_a? Module).to be_truthy
  end
end
