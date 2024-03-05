# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisDelivery::LoadVector do
  let(:druid) { "druid:#{bare_druid}" }
  let(:bare_druid) { 'cc044gt0726' }
  let(:shp_filename) { 'sanluisobispo1996.shp' }
  let(:sql_filename) { 'sanluisobispo1996.sql' }
  let(:stderr_filename) { 'shp2pgsql.err' }
  let(:cmd) { "psql --no-psqlrc --no-password --quiet --file='#{sql_filename}' " }
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
    allow(robot).to receive(:system).with(cmd, exception: true)
    allow(LyberCore::WorkflowClientFactory).to receive(:build).and_return(workflow_client)
    allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    allow(GisRobotSuite::VectorNormalizer).to receive(:new).and_return(normalizer)
  end

  context 'when the object is not a vector' do
    let(:media_type) { 'image/tiff' }
    let(:normalizer) { instance_double(GisRobotSuite::VectorNormalizer, with_normalized: true) }

    it 'does nothing' do
      test_perform(robot, druid)
      expect(normalizer).not_to have_received(:with_normalized)
      expect(robot).not_to have_received(:system).with(cmd, exception: true)
    end
  end

  context 'when the object is a vector' do
    let(:media_type) { 'application/x-esri-shapefile' }
    let(:logger) { instance_double(Logger, debug: nil, info: nil, warn: nil) }
    let(:rootdir) { GisRobotSuite.locate_druid_path bare_druid, type: :workspace }
    let(:normalizer) { GisRobotSuite::VectorNormalizer.new(logger:, bare_druid:, rootdir:) }
    let(:wkt) do
      'GEOGCS["WGS 84", DATUM["WGS_1984", SPHEROID["WGS 84",6378137,298.257223563, AUTHORITY["EPSG","7030"]], AUTHORITY["EPSG","6326"]], PRIMEM["Greenwich",0, AUTHORITY["EPSG","8901"]], UNIT["degree",0.0174532925199433, AUTHORITY["EPSG","9122"]], AUTHORITY["EPSG","4326"]]' # rubocop:disable Layout/LineLength
    end

    before do
      stub_request(:get, 'https://spatialreference.org/ref/epsg/4326/prettywkt/')
        .to_return(status: 200, body: wkt, headers: {})
      allow(robot).to receive(:normalizer).and_return(normalizer)
      allow(normalizer).to receive_messages(cleanup: true, run_shp2pgsql: true)
      @pwd = Dir.pwd
    end

    after do
      Dir.chdir(@pwd) # rubocop:disable RSpec/InstanceVariable
    end

    it 'executes system commands to load vector' do
      test_perform(robot, druid)
      expect(normalizer).to have_received(:run_shp2pgsql).with('4326', 'UTF-8', shp_filename, 'druid', sql_filename, stderr_filename)
      expect(normalizer).to have_received(:cleanup)
      expect(robot).to have_received(:system).with(cmd, exception: true)
    end

    context 'when decoding UTF-8 fails' do
      let(:decoding_err_msg) { 'Could not decode UTF-8 for some reason 🤷' }

      before do
        allow(robot.logger).to receive(:warn)
        allow(normalizer).to receive(:run_shp2pgsql) do |_projection, encoding, _shp_filename, _schema, _sql_filename, _stderr_filename|
          raise decoding_err_msg if encoding == 'UTF-8'
        end
      end

      it 'logs a warning and re-tries run_shp2pgsql with LATIN1 encoding' do
        expect { test_perform(robot, druid) }.not_to raise_error

        expect(normalizer).to have_received(:run_shp2pgsql).with('4326', 'UTF-8', shp_filename, 'druid', sql_filename, stderr_filename)

        base_err_msg = 'fell through to LATIN1 encoding after calling normalizer.run_shp2pgsql with UTF-8 encoding and encountering error'
        backtrace_regex = "#{__FILE__}:\\d+.*in .block.*; "
        expect(robot.logger).to have_received(:warn).with(/#{druid} -- #{base_err_msg}: #{decoding_err_msg}; .*#{backtrace_regex}/)
        expect(normalizer).to have_received(:run_shp2pgsql).with('4326', 'LATIN1', shp_filename, 'druid', sql_filename, stderr_filename)
      end
    end
  end
end
