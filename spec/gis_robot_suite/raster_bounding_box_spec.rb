# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::RasterBoundingBox do
  subject(:bounding_box) { described_class.new(cocina_object:, logger:, rootdir:).bounding_box }

  let(:druid) { "druid:#{bare_druid}" }
  let(:cocina_object) { build(:dro, id: druid).new(description:) }
  let(:logger) { instance_double(Logger, debug: nil, info: nil) }
  let(:rootdir) { GisRobotSuite.locate_druid_path bare_druid, type: :workspace }

  before do
    allow(GisRobotSuite).to receive(:run_system_command).and_call_original
  end

  context 'when a GeoTIFF already in EPSG:4326' do
    let(:bare_druid) { 'bb021mm7809' }
    let(:description) do
      {
        title: [{ value: 'Mobile Coverage Explorer, 2014' }],
        form: [{ value: 'EPSG::4326', type: 'map projection' }],
        geographic: [
          {
            form: [
              { value: 'image/tiff', type: 'media type', source: { value: 'IANA media type terms' } },
              { value: 'GeoTIFF', type: 'data format' }
            ]
          }
        ],
        purl: "https://purl.stanford.edu/#{bare_druid}"
      }
    end

    it 'describes the reprojection in a VRT rather than materializing the pixels' do
      expect(bounding_box).to all(be_a(Float))

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
      ulx, uly, lrx, lry = bounding_box

      expect(ulx).to be < lrx
      expect(uly).to be > lry
    end
  end

  # GDAL's ArcGRID driver could not map the bare "Projection MOLLWEIDE" in the grid's prj.adf to
  # a known CRS, so it produced ENGCRS["MOLLWEIDE"] and gdal_translate baked that into the tif.
  context 'when a GeoTIFF whose projection is an engineering CRS' do
    let(:bare_druid) { 'mk892hd7761' }
    let(:description) do
      {
        title: [{ value: 'Artisanal Fishing, 2007-2008' }],
        form: [{ value: 'ESRI::54009', type: 'map projection' }],
        geographic: [
          {
            form: [
              { value: 'image/tiff', type: 'media type', source: { value: 'IANA media type terms' } },
              { value: 'GeoTIFF', type: 'data format' }
            ]
          }
        ],
        purl: "https://purl.stanford.edu/#{bare_druid}"
      }
    end

    it 'names the projection cocina recorded, because PROJ cannot use the one in the file' do
      expect(bounding_box).to all(be_a(Float))

      expect(GisRobotSuite).to have_received(:run_system_command).with(
        a_string_including('gdalwarp -of VRT', '-s_srs ESRI:54009', '-t_srs EPSG:4326'), logger:
      )
    end
  end

  context 'when the data format is not a GeoTIFF' do
    let(:bare_druid) { 'mk892hd7761' }
    let(:description) do
      {
        title: [{ value: 'Artisanal Fishing, 2007-2008' }],
        form: [{ value: 'ESRI::54009', type: 'map projection' }],
        geographic: [
          {
            form: [
              { value: 'image/tiff', type: 'media type', source: { value: 'IANA media type terms' } },
              { value: 'ArcGRID', type: 'data format' }
            ]
          }
        ],
        purl: "https://purl.stanford.edu/#{bare_druid}"
      }
    end

    it 'raises' do
      expect { bounding_box }.to raise_error(
        'extract-boundingbox: mk892hd7761 has unsupported Raster data type: ArcGRID'
      )
    end
  end
end
