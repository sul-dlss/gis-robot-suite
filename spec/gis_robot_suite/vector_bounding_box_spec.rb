# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::VectorBoundingBox do
  subject(:bounding_box) { described_class.new(cocina_object:, logger:, rootdir:).bounding_box }

  let(:druid) { "druid:#{bare_druid}" }
  let(:cocina_object) { build(:dro, id: druid).new(description:) }
  let(:logger) { instance_double(Logger, debug: nil, info: nil) }
  let(:rootdir) { GisRobotSuite.locate_druid_path bare_druid, type: :workspace }

  let(:description) do
    {
      title: [{ value: 'Test vector data' }],
      form: [{ value: map_projection, type: 'map projection' }].compact,
      geographic: [
        {
          form: [
            { value: 'application/vnd.shp', type: 'media type', source: { value: 'IANA media type terms' } },
            { value: 'Shapefile', type: 'data format' }
          ]
        }
      ],
      purl: "https://purl.stanford.edu/#{bare_druid}"
    }
  end

  before do
    allow(GisRobotSuite).to receive(:run_system_command).and_call_original
  end

  context 'when the shapefile declares its own projection' do
    let(:bare_druid) { 'cc044gt0726' }
    let(:map_projection) { 'EPSG::3309' }

    it 'transforms the geometry in place, without writing a reprojected copy' do
      expect(bounding_box).to all(be_a(Float))

      expect(GisRobotSuite).not_to have_received(:run_system_command).with(a_string_including('gdal vector reproject'), logger:)
      expect(GisRobotSuite).not_to have_received(:run_system_command).with(a_string_including('OGRVRTDataSource'), logger:)
    end

    it 'derives a bounding box covering San Luis Obispo County' do
      ulx, uly, lrx, lry = bounding_box

      expect(ulx).to be_within(0.001).of(-121.3479)
      expect(uly).to be_within(0.001).of(35.7952)
      expect(lrx).to be_within(0.001).of(-119.4726)
      expect(lry).to be_within(0.001).of(34.8975)
    end
  end

  context 'when the shapefile has no .prj' do
    let(:bare_druid) { 'cf920rt3856' }
    let(:map_projection) { 'EPSG::32652' }

    it 'names the projection cocina recorded via an OGR VRT' do
      expect(bounding_box).to all(be_a(Float))

      expect(GisRobotSuite).to have_received(:run_system_command).with(
        a_string_including('OGRVRTDataSource', 'LayerSRS', 'EPSG:32652'), logger:
      )
    end

    it 'derives a bounding box over Pusan' do
      ulx, uly, = bounding_box

      expect(ulx).to be_within(0.001).of(129.0387)
      expect(uly).to be_within(0.001).of(35.1042)
    end
  end

  context 'when the shapefile has no .prj and cocina records no usable map projection' do
    let(:bare_druid) { 'cf920rt3856' }
    let(:map_projection) { 'World_Mollweide' } # a name, not an authority and code

    it 'raises' do
      expect { bounding_box }.to raise_error(
        'extract-boundingbox: cf920rt3856 Pusan_CBD has no spatial reference system ' \
        'and cocina records no map projection to fall back on'
      )
    end
  end

  context 'when the shapefile is already in EPSG:4326' do
    let(:bare_druid) { 'cz128vq0535' }
    let(:map_projection) { 'EPSG::4326' }

    it 'returns the native extent unchanged' do
      ulx, uly, lrx, lry = bounding_box

      expect(ulx).to be_within(0.0001).of(29.5727423617)
      expect(uly).to be_within(0.0001).of(4.2340766311)
      expect(lrx).to be_within(0.0001).of(35.0003080361)
      expect(lry).to be_within(0.0001).of(-1.4787935059)
    end
  end
end
