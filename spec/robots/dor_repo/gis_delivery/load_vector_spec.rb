# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisDelivery::LoadVector do
  let(:druid) { "druid:#{bare_druid}" }
  let(:bare_druid) { 'cc044gt0726' }
  let(:normalizer_tmpdir) { "/tmp/normalizevector_#{bare_druid}" }
  let(:shp_filename) { "#{normalizer_tmpdir}/sanluisobispo1996.shp" }
  let(:sql_filename) { "#{normalizer_tmpdir}/sanluisobispo1996.sql" }
  let(:stderr_filename) { "#{normalizer_tmpdir}/shp2pgsql.err" }
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
    allow(robot).to receive(:system)
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
      expect(robot).not_to have_received(:system)
    end
  end

  context 'when the object is a vector' do
    let(:media_type) { 'application/x-esri-shapefile' }
    let(:logger) { instance_double(Logger, debug: nil, info: nil, warn: nil) }
    let(:rootdir) { GisRobotSuite.locate_druid_path bare_druid, type: :workspace }
    let(:normalizer) { GisRobotSuite::VectorNormalizer.new(logger:, bare_druid:, rootdir:) }
    let(:cmd_psql) { "psql --no-psqlrc --no-password --quiet --file='#{sql_filename}' " }
    let(:cmd_shp2pgsql) { "shp2pgsql -s 4326 -d -D -I -W UTF-8 '#{shp_filename}' druid.#{bare_druid} > '#{sql_filename}' 2> '#{stderr_filename}'" }
    let(:wkt) do
      'GEOGCS["WGS 84", DATUM["WGS_1984", SPHEROID["WGS 84",6378137,298.257223563, AUTHORITY["EPSG","7030"]], AUTHORITY["EPSG","6326"]], PRIMEM["Greenwich",0, AUTHORITY["EPSG","8901"]], UNIT["degree",0.0174532925199433, AUTHORITY["EPSG","9122"]], AUTHORITY["EPSG","4326"]]' # rubocop:disable Layout/LineLength
    end

    before do
      stub_request(:get, 'https://spatialreference.org/ref/epsg/4326/prettywkt/')
        .to_return(status: 200, body: wkt, headers: {})
      allow(robot).to receive(:normalizer).and_return(normalizer)
      allow(normalizer).to receive_messages(cleanup: true)
      allow(File).to receive(:size?).and_call_original
      allow(File).to receive(:size?).with(sql_filename).and_return('123')
    end

    it 'executes system commands to load vector' do
      test_perform(robot, druid)
      expect(normalizer).to have_received(:cleanup)
      expect(robot).to have_received(:system).with(cmd_shp2pgsql, exception: true)
      expect(robot).to have_received(:system).with(cmd_psql, exception: true)
    end

    context 'when decoding UTF-8 fails' do
      let(:decoding_err_msg) { 'Could not decode UTF-8 for some reason 🤷' }
      let(:cmd_shp2pgsql_retry) { "shp2pgsql -s 4326 -d -D -I -W LATIN1 '#{shp_filename}' druid.#{bare_druid} > '#{sql_filename}' 2> '#{stderr_filename}'" }

      before do
        allow(robot.logger).to receive(:warn)
        allow(robot).to receive(:system) do |cmd|
          raise decoding_err_msg if cmd.include?('-W UTF-8')
        end
      end

      it 'logs a warning and re-tries shp2pgsql with LATIN1 encoding' do
        expect { test_perform(robot, druid) }.not_to raise_error

        expect(robot).to have_received(:system).with(cmd_shp2pgsql, exception: true)

        base_err_msg = 'fell through to LATIN1 encoding after calling run_shp2pgsql with UTF-8 encoding and encountering error'
        backtrace_regex = "#{__FILE__}:\\d+.*in .block.*; "
        expect(robot.logger).to have_received(:warn).with(/#{druid} -- #{base_err_msg}: #{decoding_err_msg}; .*#{backtrace_regex}/)
        expect(robot).to have_received(:system).with(cmd_shp2pgsql_retry, exception: true)
      end
    end
  end
end
