# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisDelivery::LoadRaster do
  let(:druid) { 'bc123df4567' }
  let(:rootdir) { '/dor/workspace/druid:bc123df4567' }
  let(:tiffn) { 'bc123df4567.tif' }
  let(:path) { '/geotiff' }
  let(:cmd) { "rsync -v '#{tiffn}' #{path}/bc123df4567.tif" }
  let(:cmd_aux) { "rsync -v '#{tiffn}'.aux.xml #{path}/bc123df4567.tif.aux.xml" }
  let(:robot) { described_class.new }
  let(:workflow_client) { instance_double(Dor::Workflow::Client) }
  let(:object_client) { instance_double(Dor::Services::Client::Object, find: cocina_object) }
  let(:cocina_object) do
    dro = build(:dro)
    dro.new(description: dro.description.new(geographic: [
                                               { form: [{ type: 'media type', value: media_type }, { type: 'data format', value: 'GeoTIFF' }] }
                                             ]))
  end

  before do
    allow(Dir).to receive(:chdir).with('spec/fixtures/workspace/bc/123/df/4567/bc123df4567')
    allow(Dir).to receive(:glob).with('*.tif').and_return([tiffn])
    allow(robot).to receive(:system).with(cmd, exception: true)
    allow(robot).to receive(:system).with(cmd_aux, exception: true)
    allow(LyberCore::WorkflowClientFactory).to receive(:build).and_return(workflow_client)
    allow(Dor::Services::Client).to receive(:object).and_return(object_client)
  end

  context 'when the object is not a raster' do
    let(:media_type) { 'application/x-esri-shapefile' }

    it 'does nothing' do
      test_perform(robot, druid)
      expect(robot).not_to have_received(:system).with(cmd, exception: true)
      expect(robot).not_to have_received(:system).with(cmd_aux, exception: true)
    end
  end

  context 'when the object is a raster' do
    let(:media_type) { 'image/tiff' }

    it 'executes system commands to load raster' do
      test_perform(robot, druid)
      expect(robot).to have_received(:system).with(cmd, exception: true)
      expect(robot).to have_received(:system).with(cmd_aux, exception: true)
    end
  end
end
