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
  let(:logger) { robot.logger }
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
    allow(GisRobotSuite).to receive(:run_system_command).and_call_original
    allow(LyberCore::WorkflowClientFactory).to receive(:build).and_return(workflow_client)
    allow(Dor::Services::Client).to receive(:object).and_return(object_client)
  end

  context 'when the object is not a vector' do
    let(:media_type) { 'image/tiff' }

    before do
      allow(GisRobotSuite::VectorNormalizer).to receive(:new)
      allow(logger).to receive(:info)
    end

    it 'does nothing' do
      test_perform(robot, druid)
      expect(logger).to have_received(:info).with("load-vector: #{bare_druid} is not a vector, skipping")
      expect(GisRobotSuite::VectorNormalizer).not_to have_received(:new)
      expect(GisRobotSuite).not_to have_received(:run_system_command)
    end
  end

  context 'when the object is a vector' do
    let(:media_type) { 'application/x-esri-shapefile' }
    let(:rootdir) { GisRobotSuite.locate_druid_path bare_druid, type: :workspace }
    let(:cmd_psql) { "psql --no-psqlrc --no-password --quiet --file='#{sql_filename}' " }
    let(:cmd_shp2pgsql) { "shp2pgsql -s 4326 -d -D -I -W UTF-8 '#{shp_filename}' druid.#{bare_druid} > '#{sql_filename}' 2> '#{stderr_filename}'" }
    let(:wkt) do
      'GEOGCS["WGS 84", DATUM["WGS_1984", SPHEROID["WGS 84",6378137,298.257223563, AUTHORITY["EPSG","7030"]], AUTHORITY["EPSG","6326"]], PRIMEM["Greenwich",0, AUTHORITY["EPSG","8901"]], UNIT["degree",0.0174532925199433, AUTHORITY["EPSG","9122"]], AUTHORITY["EPSG","4326"]]' # rubocop:disable Layout/LineLength
    end

    before do
      stub_request(:get, 'https://spatialreference.org/ref/epsg/4326/prettywkt/')
        .to_return(status: 200, body: wkt, headers: {})
      allow(robot).to receive(:logger).and_return(logger)
      allow(GisRobotSuite).to receive(:run_system_command).with(cmd_shp2pgsql, logger:)
      allow(GisRobotSuite).to receive(:run_system_command).with(cmd_psql, logger:)
      allow(File).to receive(:size?).and_call_original
      allow(File).to receive(:size?).with(sql_filename).and_return('123')
    end

    it 'executes system commands to load vector' do
      test_perform(robot, druid)
      actual_tmpdir = robot.send(:normalizer).send(:tmpdir)
      expect(File.exist?(actual_tmpdir)).to be false # LoadVector#normalizer.with_normalized should call cleanup, which should get rid of the temp dir
      expect(actual_tmpdir).to eq(normalizer_tmpdir) # confirm that the expected temp dir path we're using for other comparisons is accurate
      expect(GisRobotSuite).to have_received(:run_system_command).with(cmd_shp2pgsql, logger:)
      expect(GisRobotSuite).to have_received(:run_system_command).with(cmd_psql, logger:)
    end

    context 'when decoding UTF-8 fails' do
      let(:decoding_err_msg) { 'Could not decode UTF-8 for some reason 🤷' }
      let(:cmd_shp2pgsql_retry) { "shp2pgsql -s 4326 -d -D -I -W LATIN1 '#{shp_filename}' druid.#{bare_druid} > '#{sql_filename}' 2> '#{stderr_filename}'" }

      before do
        allow(robot.logger).to receive(:warn)
        allow(GisRobotSuite).to receive(:run_system_command).with(cmd_shp2pgsql, logger:) do |cmd|
          raise decoding_err_msg if cmd.include?('-W UTF-8')
        end
        allow(GisRobotSuite).to receive(:run_system_command).with(cmd_shp2pgsql_retry, logger:)
      end

      it 'logs a warning and re-tries shp2pgsql with LATIN1 encoding' do
        expect { test_perform(robot, druid) }.not_to raise_error

        expect(GisRobotSuite).to have_received(:run_system_command).with(cmd_shp2pgsql, logger:)

        base_err_msg = 'fell through to LATIN1 encoding after calling run_shp2pgsql with UTF-8 encoding and encountering error'
        backtrace_regex = "#{__FILE__}:\\d+.*in .block.*; "
        expect(robot.logger).to have_received(:warn).with(/#{druid} -- #{base_err_msg}: #{decoding_err_msg}; .*#{backtrace_regex}/)
        expect(GisRobotSuite).to have_received(:run_system_command).with(cmd_shp2pgsql_retry, logger:)
      end
    end
  end
end
