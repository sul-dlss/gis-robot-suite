# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite do
  let(:cocina_object) do
    dro = build(:dro)
    dro.new(description: dro.description.new(geographic: [
                                               { form: [{ type: 'media type', value: media_type }, { type: 'data format', value: data_format }] }
                                             ]))
  end
  let(:media_type) { 'image/tiff ' }
  let(:data_format) { 'GeoTIFF' }

  describe '.media_type' do
    it 'returns media type' do
      expect(described_class.media_type(cocina_object)).to eq(media_type)
    end
  end

  describe '.data_format' do
    it 'returns data format' do
      expect(described_class.data_format(cocina_object)).to eq(data_format)
    end
  end

  describe '.vector?' do
    context 'when a vector' do
      let(:media_type) { 'application/x-esri-shapefile' }

      it 'returns true' do
        expect(described_class).to be_vector(cocina_object)
      end
    end

    context 'when not a vector' do
      let(:media_type) { 'image/tiff' }

      it 'returns false' do
        expect(described_class).not_to be_vector(cocina_object)
      end
    end
  end

  describe '.raster?' do
    context 'when a raster' do
      let(:media_type) { 'image/tiff' }

      it 'returns true' do
        expect(described_class).to be_raster(cocina_object)
      end
    end

    context 'when not a raster' do
      let(:media_type) { 'application/x-esri-shapefile' }

      it 'returns false' do
        expect(described_class).not_to be_raster(cocina_object)
      end
    end

    context 'when an ArcGrid raster' do
      let(:media_type) { 'application/x-ogc-aig' }

      it 'raises' do
        expect { described_class.raster?(cocina_object) }.to raise_error(RuntimeError, "druid:bc234fg5678 is ArcGrid format: 'application/x-ogc-aig'")
      end
    end
  end

  describe '.determine_rights' do
    subject { described_class.determine_rights(cocina_object) }

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

  describe '.layertype' do
    let(:cocina_object) do
      dro = build(:dro)
      dro.new(description: dro.description.new(geographic: [
                                                 { form: [{ type: 'media type', value: media_type }, { type: 'data format', value: data_format }] }
                                               ]))
    end

    context 'when an unknown media type' do
      let(:media_type) { 'something/else' }

      it 'raises' do
        expect { described_class.layertype(cocina_object) }.to raise_error(RuntimeError, 'druid:bc234fg5678 has unknown format: something/else')
      end
    end

    context 'when a vector' do
      let(:media_type) { 'application/x-esri-shapefile' }

      it 'has layertype PostGIS' do
        expect(described_class.layertype(cocina_object)).to eq 'PostGIS'
      end
    end

    context 'when a raster' do
      let(:media_type) { 'image/tiff' }

      it 'has layertype GeoTIFF' do
        expect(described_class.layertype(cocina_object)).to eq 'GeoTIFF'
      end
    end
  end

  describe '.determine_raster_style' do
    let(:rgb8_file) { File.join(fixture_dir, 'tif_files/MCE_AF2G_2010.tif') }
    let(:grayscale8_file) { File.join(fixture_dir, 'stage/bh432xr2264/temp/51002.tif') }

    after do
      # the *.aux.xml files are written by gdalinfo when it computes image statistics (will be regenerated if not present)
      FileUtils.rm_rf("#{rgb8_file}.aux.xml")
      FileUtils.rm_rf("#{grayscale8_file}.aux.xml")
    end

    it 'determines the correct raster style' do
      expect(described_class.determine_raster_style(rgb8_file)).to eq('rgb8')
      expect(described_class.determine_raster_style(grayscale8_file)).to eq('grayscale8')
    end
  end
end
