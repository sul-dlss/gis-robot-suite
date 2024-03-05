# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisDelivery::LoadRaster do
  let(:druid) { "druid:#{bare_druid}" }
  let(:bare_druid) { 'bb021mm7809' }
  let(:tif_filename) { 'MCE_FI2G_2014.tif' }
  let(:destination_path) { '/geotiff' }
  let(:cmd_tif_sync) { "rsync -v '#{tif_filename}' #{destination_path}/#{bare_druid}.tif" }
  let(:cmd_aux_sync) { "rsync -v '#{tif_filename}'.aux.xml #{destination_path}/#{bare_druid}.tif.aux.xml" }
  let(:robot) { described_class.new }
  let(:workflow_client) { instance_double(Dor::Workflow::Client) }
  let(:object_client) { instance_double(Dor::Services::Client::Object, find: cocina_object) }
  let(:cocina_object) { build(:dro, id: druid).new(description:) }
  let(:description) do
    {
      title: [
        {
          value: 'Finland 2G Mobile Coverage Explorer, 2014'
        }
      ],
      geographic: [
        {
          form: [
            {
              value: media_type,
              type: 'media type',
              source: {
                value: 'IANA media type terms'
              }
            },
            {
              value: 'GeoTIFF',
              type: 'data format'
            },
            {
              value: 'Dataset#',
              type: 'type'
            }
          ],
          subject: [
            {
              structuredValue: [
                {
                  value: '16.1179474',
                  type: 'west'
                },
                {
                  value: '59.2022116',
                  type: 'south'
                },
                {
                  value: '32.2367687',
                  type: 'east'
                },
                {
                  value: '70.6126121',
                  type: 'north'
                }
              ],
              type: 'bounding box coordinates',
              standard: {
                code: 'EPSG:4326'
              },
              encoding: {
                value: 'decimal'
              }
            },
            {
              value: 'Finland',
              type: 'coverage',
              valueLanguage: {
                code: 'eng'
              }
            }
          ]
        }
      ],
      purl: "https://purl.stanford.edu/#{bare_druid}"
    }
  end

  before do
    allow(robot).to receive(:system).with(cmd_tif_sync, exception: true)
    allow(robot).to receive(:system).with(cmd_aux_sync, exception: true)
    allow(LyberCore::WorkflowClientFactory).to receive(:build).and_return(workflow_client)
    allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    allow(Kernel).to receive(:system).and_call_original
  end

  context 'when the object is not a raster' do
    let(:media_type) { 'application/x-esri-shapefile' }
    let(:normalizer) { instance_double(GisRobotSuite::RasterNormalizer, with_normalized: true) }

    before { allow(GisRobotSuite::RasterNormalizer).to receive(:new).and_return(normalizer) }

    it 'does nothing' do
      test_perform(robot, druid)
      expect(normalizer).not_to have_received(:with_normalized)
      expect(robot).not_to have_received(:system).with(cmd_tif_sync, exception: true)
      expect(robot).not_to have_received(:system).with(cmd_aux_sync, exception: true)
    end
  end

  context 'when the object is a raster' do
    let(:media_type) { 'image/tiff' }

    it 'executes system commands to load raster' do
      test_perform(robot, druid)
      expect(robot).to have_received(:system).with(cmd_tif_sync, exception: true)
      expect(robot).to have_received(:system).with(cmd_aux_sync, exception: true)
    end
  end
end
