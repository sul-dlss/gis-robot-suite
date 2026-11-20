# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::RasterBoundingBox do
  subject(:bounding_box) { described_class.new(rootdir:, esri_ng:, logger:, bare_druid:).bounding_box }

  # The ArcGIS metadata staged alongside the raster
  let(:esri_ng) { Nokogiri::XML(File.read(Dir.glob("#{rootdir}/content/*.tif.xml").first)) }
  let(:logger) { instance_double(Logger, debug: nil, info: nil) }
  let(:rootdir) { GisRobotSuite.locate_druid_path bare_druid, type: :workspace }

  before do
    allow(GisRobotSuite).to receive(:run_system_command).and_call_original
  end

  context 'when a GeoTIFF already in EPSG:4326' do
    let(:bare_druid) { 'bb021mm7809' }

    it 'describes the reprojection in a VRT rather than materializing the pixels' do
      expect(bounding_box.to_h.values).to all(be_a(Float))

      expect(GisRobotSuite).to have_received(:run_system_command).with(
        a_string_including('gdalwarp -of VRT', '-t_srs EPSG:4326'), logger:
      )
      expect(GisRobotSuite).not_to have_received(:run_system_command).with(a_string_including('gdal_translate'), logger:)
      expect(GisRobotSuite).not_to have_received(:run_system_command).with(a_string_including('gdal raster reproject'), logger:)
    end

    it 'leaves no VRT behind' do
      bounding_box

      expect(Dir.glob('/tmp/boundingbox*.vrt')).to be_empty
    end

    it 'derives a plausible bounding box' do
      ulx, uly, lrx, lry = bounding_box.to_h.values_at(:west, :north, :east, :south)

      expect(ulx).to be < lrx
      expect(uly).to be > lry
    end

    it 'warps only once, because the extent is narrower than a hemisphere' do
      bounding_box

      expect(GisRobotSuite).not_to have_received(:run_system_command).with(a_string_including('CENTER_LONG'), logger:)
    end
  end

  context 'when a GeoTIFF straddles the antimeridian' do
    let(:bare_druid) { 'kr180pm0002' }

    it 'warps again centred on 180°, because the first warp spans the world' do
      bounding_box

      expect(GisRobotSuite).to have_received(:run_system_command).with(
        a_string_including('gdalwarp -of VRT', '--config CENTER_LONG 180', '-t_srs EPSG:4326'), logger:
      )
    end

    it 'spans the antimeridian rather than the world, west greater than east' do
      ulx, uly, lrx, lry = bounding_box.to_h.values_at(:west, :north, :east, :south)

      expect(ulx).to be_within(0.01).of(176.10)
      expect(uly).to be_within(0.01).of(4.52)
      expect(lrx).to be_within(0.01).of(-178.50)
      expect(lry).to be_within(0.05).of(0.0)
    end
  end

  # GDAL's ArcGRID driver could not map the bare "Projection MOLLWEIDE" in the grid's prj.adf to
  # a known CRS, so it produced ENGCRS["MOLLWEIDE"] and gdal_translate baked that into the tif.
  context 'when a GeoTIFF whose projection is an engineering CRS' do
    let(:bare_druid) { 'mk892hd7761' }

    it 'names the projection the ArcGIS metadata records, because PROJ cannot use the one in the file' do
      expect(bounding_box.to_h.values).to all(be_a(Float))

      # Twice, since the data spans the world: once as is and once centred on 180°.
      expect(GisRobotSuite).to have_received(:run_system_command).with(
        a_string_including('gdalwarp -of VRT', '-s_srs ESRI:54009', '-t_srs EPSG:4326'), logger:
      ).twice
    end

    it 'still spans the world, as measured either way' do
      ulx, lrx = bounding_box.to_h.values_at(:west, :east)

      expect([ulx, lrx]).to eq [-180.0, 180.0]
    end
  end

  context 'when a GeoTIFF declares no usable projection and the ArcGIS metadata names none' do
    let(:bare_druid) { 'mk892hd7761' }
    let(:esri_ng) { Nokogiri::XML('<metadata/>') }

    it 'raises' do
      expect { bounding_box }.to raise_error(
        'bounding box: mk892hd7761 artisanal has no usable spatial reference system ' \
        'and the ArcGIS metadata names none to fall back on'
      )
    end
  end
end
