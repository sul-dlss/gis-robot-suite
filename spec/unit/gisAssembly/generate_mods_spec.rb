# encoding: utf-8

require 'spec_helper'
require_relative '../../../config/boot'

describe Robots::DorRepo::GisAssembly::GenerateMods do

  it 'converts DD to DDMMSS' do
    expect(subject.dd2ddmmss_abs('-109.758319')).to eq('109°45ʹ30ʺ')
    expect(subject.dd2ddmmss_abs('48.999336')).to eq('48°59ʹ58ʺ')
  end

  it 'converts MARC to DDMMSS' do
    expect(subject.to_coordinates_ddmmss('-180 -- 180/90 -- -90')).to eq('W 180°--E 180°/N 90°--S 90°')
    expect(subject.to_coordinates_ddmmss('-109.758319 -- -88.990844/48.999336 -- 29.423028')).to eq('W 109°45ʹ30ʺ--W 88°59ʹ27ʺ/N 48°59ʹ58ʺ--N 29°25ʹ23ʺ')
  end

  it 'handles bad arguments' do
    expect {subject.to_coordinates_ddmmss('-185 -- 185/95 -- -95')}.to raise_error(ArgumentError)
  end

end
