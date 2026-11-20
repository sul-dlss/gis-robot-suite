# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::BoundingBox do
  describe '.new' do
    it 'accepts a box crossing the antimeridian, west greater than east' do
      box = described_class.new(west: 169.5, east: -143.1, north: 4.7, south: -17.9)

      expect(box).to be_crosses_antimeridian
    end

    it 'rejects south above north' do
      expect { described_class.new(west: 10.0, east: 20.0, north: -5.0, south: 5.0) }.to raise_error(ArgumentError, /invalid bounding box/)
    end

    it 'rejects a longitude outside [-180, 180]' do
      expect { described_class.new(west: 170.0, east: 190.0, north: 5.0, south: -5.0) }.to raise_error(ArgumentError, /invalid bounding box/)
    end
  end

  describe '.from_data' do
    subject(:bounding_box) { described_class.from_data(rootdir:, esri_ng: Nokogiri::XML('<metadata/>'), logger:, bare_druid:) }

    let(:logger) { instance_double(Logger, debug: nil, info: nil) }
    let(:rootdir) { GisRobotSuite.locate_druid_path bare_druid, type: :workspace }

    context 'with a shapefile or GeoJSON staged' do
      let(:bare_druid) { 'kr180pm0001' }

      it 'measures it as a vector' do
        expect(bounding_box).to have_attributes(west: be_within(0.0001).of(178.0), east: be_within(0.0001).of(-178.0))
      end
    end

    context 'with a GeoTIFF staged' do
      let(:bare_druid) { 'kr180pm0002' }

      it 'measures it as a raster' do
        expect(bounding_box).to have_attributes(west: be_within(0.01).of(176.10), east: be_within(0.01).of(-178.50))
      end
    end

    context 'with no data staged' do
      let(:rootdir) { Dir.mktmpdir }
      let(:bare_druid) { 'bb045mm1234' }

      after { FileUtils.rm_rf(rootdir) }

      it 'raises' do
        expect { bounding_box }.to raise_error(/bb045mm1234 has no shapefile, GeoJSON or GeoTIFF/)
      end
    end
  end
end
