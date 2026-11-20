# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::Antimeridian do
  describe '.longitudes' do
    it 'keeps the plain measurement of data clear of the antimeridian, untouched' do
      expect(described_class.longitudes([56.2499964, 72.368695], [56.2499964, 72.368695])).to eq [56.2499964, 72.368695]
    end

    it 'keeps the plain measurement of data straddling the prime meridian' do
      expect(described_class.longitudes([-10.0, 30.0], [0.0, 350.0])).to eq [-10.0, 30.0]
    end

    it 'keeps the shifted measurement of data either side of the antimeridian, west greater than east' do
      expect(described_class.longitudes([-174.543396, 176.848694], [169.520798, 216.933701]))
        .to match [be_within(1e-9).of(169.520798), be_within(1e-9).of(-143.066299)]
    end

    it 'brings a measurement centred on 180° back into [-180, 180]' do
      expect(described_class.longitudes([-180.0, 178.71], [176.1, 181.5]))
        .to match [be_within(1e-9).of(176.1), be_within(1e-9).of(-178.5)]
    end

    it 'brings data stated in [0, 360] back into [-180, 180]' do
      expect(described_class.longitudes([200.0, 210.0])).to eq [-160.0, -150.0]
    end

    it 'describes data covering every longitude as the whole world' do
      expect(described_class.longitudes([0.0, 360.0])).to eq [-180.0, 180.0]
      expect(described_class.longitudes([-180.0, 180.0], [0.0, 360.0])).to eq [-180.0, 180.0]
    end
  end
end
