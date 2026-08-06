# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::VectorDerivativeGenerator do
  describe '.generate' do
    subject(:generate) do
      described_class.generate(input_path: input_path, fgb_path: fgb_path, pmtiles_path: pmtiles_path, logger: logger)
    end

    let(:input_path) { Pathname.new('/path/to/layer.shp') }
    let(:fgb_path) { Pathname.new('/path/to/output.fgb') }
    let(:pmtiles_path) { Pathname.new('/path/to/output.pmtiles') }
    let(:logger) { instance_double(Logger, info: nil, warn: nil, debug: nil) }

    context 'when tippecanoe can guess a maxzoom' do
      before do
        allow(GisRobotSuite).to receive(:run_system_command)
      end

      it 'generates the FlatGeoBuf and PMTiles using -zg' do
        generate

        expect(GisRobotSuite).to have_received(:run_system_command).with(a_string_including('ogr2ogr'), logger: logger)
        expect(GisRobotSuite).to have_received(:run_system_command).with(a_string_including('tippecanoe'), logger: logger).once
        expect(GisRobotSuite).to have_received(:run_system_command).with(a_string_including('-zg'), logger: logger)
      end
    end

    context 'when tippecanoe cannot guess a maxzoom (-zg)' do
      let(:maxzoom_error) do
        GisRobotSuite::SystemCommandNonzeroExit.new(
          'Unsuccessful attempt executing system command: result={cmd: "tippecanoe ...", stdout_str: "", ' \
          "stderr_str: \"Can't guess maxzoom (-zg) without at least two distinct feature locations\\n\", exitstatus: 110, success: false}"
        )
      end

      before do
        allow(GisRobotSuite).to receive(:run_system_command) do |command, **|
          raise maxzoom_error if command.include?('-zg')
        end
      end

      it 'retries tippecanoe with a fixed maxzoom of 14' do
        generate

        expect(GisRobotSuite).to have_received(:run_system_command).with(a_string_including('-zg'), logger: logger)
        expect(GisRobotSuite).to have_received(:run_system_command).with(a_string_including('-z14'), logger: logger)
      end

      it 'logs a warning' do
        generate

        expect(logger).to have_received(:warn).with(a_string_including('Falling back to maxzoom=14'))
      end
    end

    context 'when tippecanoe fails for an unrelated reason' do
      let(:unrelated_error) { GisRobotSuite::SystemCommandNonzeroExit.new('boom') }

      before do
        allow(GisRobotSuite).to receive(:run_system_command) do |command, **|
          raise unrelated_error if command.include?('tippecanoe')
        end
      end

      it 're-raises without retrying' do
        expect { generate }.to raise_error(GisRobotSuite::SystemCommandNonzeroExit, 'boom')
        expect(GisRobotSuite).to have_received(:run_system_command).with(a_string_including('tippecanoe'), logger: logger).once
      end
    end
  end
end
