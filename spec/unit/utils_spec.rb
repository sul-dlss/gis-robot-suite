# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'utilities' do
  let(:cocina_object) do
    dro = build(:dro)
    dro.new(description: dro.description.new(geographic: [
                                               { form: [{ type: 'media type', value: media_type }, { type: 'data format', value: data_format }] }
                                             ]))
  end
  let(:media_type) { 'application/x-ogc-aig' }
  let(:data_format) { 'GeoTIFF' }

  describe '.media_type' do
    it 'returns media type' do
      expect(GisRobotSuite.media_type(cocina_object)).to eq(media_type)
    end
  end

  describe '.data_format' do
    it 'returns data format' do
      expect(GisRobotSuite.data_format(cocina_object)).to eq(data_format)
    end
  end

  describe '.vector?' do
    context 'when a vector' do
      let(:media_type) { 'application/x-esri-shapefile' }

      it 'returns true' do
        expect(GisRobotSuite).to be_vector(cocina_object)
      end
    end

    context 'when not a vector' do
      let(:media_type) { 'image/tiff' }

      it 'returns false' do
        expect(GisRobotSuite).not_to be_vector(cocina_object)
      end
    end
  end

  describe '.raster?' do
    context 'when a raster' do
      let(:media_type) { 'image/tiff' }

      it 'returns true' do
        expect(GisRobotSuite).to be_raster(cocina_object)
      end
    end

    context 'when not a raster' do
      let(:media_type) { 'application/x-esri-shapefile' }

      it 'returns false' do
        expect(GisRobotSuite).not_to be_raster(cocina_object)
      end
    end
  end

  describe '.determine_rights' do
    subject { GisRobotSuite.determine_rights(cocina_object) }

    let(:cocina_object) { build(:dro).new(access: { view: access, download: access }) }

    context 'when public' do
      let(:access) { 'world' }

      it { is_expected.to eq 'public' }
    end

    context 'when restricted' do
      let(:access) { 'stanford' }

      it { is_expected.to eq 'restricted' }
    end
  end
end
