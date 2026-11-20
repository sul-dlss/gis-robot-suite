# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::VectorBoundingBox do
  subject(:bounding_box) { described_class.new(rootdir:, esri_ng:, logger:, bare_druid:).bounding_box }

  let(:logger) { instance_double(Logger, debug: nil, info: nil) }
  let(:rootdir) { GisRobotSuite.locate_druid_path bare_druid, type: :workspace }
  # The ArcGIS metadata, reduced to the reference system it names
  let(:esri_ng) do
    Nokogiri::XML(<<~XML)
      <metadata>
        <refSysInfo><RefSystem><refSysID><identCode code="#{esri_code}"/><idCodeSpace>EPSG</idCodeSpace></refSysID></RefSystem></refSysInfo>
      </metadata>
    XML
  end
  let(:esri_code) { '' }

  before do
    allow(GisRobotSuite).to receive(:run_system_command).and_call_original
  end

  context 'when the shapefile declares its own projection' do
    let(:bare_druid) { 'cc044gt0726' }
    let(:esri_code) { '3309' }

    it 'transforms the geometry in place, without writing a reprojected copy' do
      expect(bounding_box.to_h.values).to all(be_a(Float))

      expect(GisRobotSuite).not_to have_received(:run_system_command).with(a_string_including('gdal vector reproject'), logger:)
      expect(GisRobotSuite).not_to have_received(:run_system_command).with(a_string_including('OGRVRTDataSource'), logger:)
    end

    it 'derives a bounding box covering San Luis Obispo County' do
      ulx, uly, lrx, lry = bounding_box.to_h.values_at(:west, :north, :east, :south)

      expect(ulx).to be_within(0.001).of(-121.3479)
      expect(uly).to be_within(0.001).of(35.7952)
      expect(lrx).to be_within(0.001).of(-119.4726)
      expect(lry).to be_within(0.001).of(34.8975)
    end
  end

  context 'when the shapefile has no .prj' do
    let(:bare_druid) { 'cf920rt3856' }
    let(:esri_code) { '32652' }

    it 'names the projection the ArcGIS metadata records via an OGR VRT' do
      expect(bounding_box.to_h.values).to all(be_a(Float))

      expect(GisRobotSuite).to have_received(:run_system_command).with(
        a_string_including('OGRVRTDataSource', 'LayerSRS', 'EPSG:32652'), logger:
      )
    end

    it 'derives a bounding box over Pusan' do
      ulx, uly = bounding_box.to_h.values_at(:west, :north)

      expect(ulx).to be_within(0.001).of(129.0387)
      expect(uly).to be_within(0.001).of(35.1042)
    end
  end

  context 'when the shapefile has no .prj and the ArcGIS metadata names no reference system' do
    let(:bare_druid) { 'cf920rt3856' }

    it 'raises' do
      expect { bounding_box }.to raise_error(
        'bounding box: cf920rt3856 Pusan_CBD has no spatial reference system ' \
        'and the ArcGIS metadata names none to fall back on'
      )
    end
  end

  context 'when the data lies either side of the antimeridian' do
    let(:bare_druid) { 'kr180pm0001' }
    let(:esri_code) { '4326' }

    it 'spans the antimeridian rather than the world, west greater than east' do
      ulx, uly, lrx, lry = bounding_box.to_h.values_at(:west, :north, :east, :south)

      expect(ulx).to be_within(0.0001).of(178.0)
      expect(uly).to be_within(0.0001).of(1.0)
      expect(lrx).to be_within(0.0001).of(-178.0)
      expect(lry).to be_within(0.0001).of(-1.0)
    end
  end

  context 'when the shapefile is already in EPSG:4326' do
    let(:bare_druid) { 'cz128vq0535' }
    let(:esri_code) { '4326' }

    it 'returns the native extent unchanged' do
      ulx, uly, lrx, lry = bounding_box.to_h.values_at(:west, :north, :east, :south)

      expect(ulx).to be_within(0.0001).of(29.5727423617)
      expect(uly).to be_within(0.0001).of(4.2340766311)
      expect(lrx).to be_within(0.0001).of(35.0003080361)
      expect(lry).to be_within(0.0001).of(-1.4787935059)
    end
  end
end
