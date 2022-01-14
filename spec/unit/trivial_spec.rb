# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'booting' do
  it 'can boot gisAssembly' do
    expect(Robots::DorRepo::GisAssembly).to be_a(Module)
  end

  it 'can boot gisDelivery' do
    expect(Robots::DorRepo::GisDelivery).to be_a(Module)
  end
end
