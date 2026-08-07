# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::VectorPreviewGenerator do
  describe '.generate' do
    let(:input_path) { Pathname.new('/path/to/input.shp') }
    let(:output_path) { Pathname.new('/path/to/output.jp2') }
    let(:temp_tif_path) { Pathname.new('/path/to/output_temp.tif') }
    let(:logger) { instance_double(Logger, info: nil, warn: nil, debug: nil) }

    before do
      allow(GisRobotSuite).to receive(:run_system_command)
      allow(FileUtils).to receive(:rm_f)
    end

    it 'rasterizes the vector, converts the TIFF, and cleans up' do
      described_class.generate(input_path: input_path, output_path: output_path, logger: logger)

      expect(GisRobotSuite).to have_received(:run_system_command).with(
        "gdal vector rasterize --size 512,512 --burn 255 --ot Byte #{Shellwords.escape(input_path.to_s)} #{Shellwords.escape(temp_tif_path.to_s)}",
        logger: logger
      )

      expect(GisRobotSuite).to have_received(:run_system_command).with(
        "gdal convert --overwrite --co QUALITY=25 --co REVERSIBLE=NO #{Shellwords.escape(temp_tif_path.to_s)} #{Shellwords.escape(output_path.to_s)}",
        logger: logger
      )

      expect(FileUtils).to have_received(:rm_f).with(temp_tif_path)
    end

    context 'when gdal cannot determine bounds (e.g. a single-point layer)' do
      let(:bounds_error) do
        GisRobotSuite::SystemCommandNonzeroExit.new(
          'Unsuccessful attempt executing system command: result={cmd: "gdal vector rasterize ...", stdout_str: "", ' \
          'stderr_str: "ERROR 1: Could not determine bounds\n", exitstatus: 1, success: false}'
        )
      end
      let(:info_result) do
        { stdout_str: '{"layers":[{"geometryFields":[{"extent":[10.0,20.0,10.0,20.0]}]}]}' }
      end

      before do
        allow(GisRobotSuite).to receive(:run_system_command) do |command, **|
          raise bounds_error if command.include?('rasterize') && !command.include?('--extent')

          info_result if command.include?('gdal vector info')
        end
      end

      it 'retries rasterization with a padded explicit extent' do
        described_class.generate(input_path: input_path, output_path: output_path, logger: logger)

        expect(GisRobotSuite).to have_received(:run_system_command).with(a_string_including('--extent 9.98,19.98,10.02,20.02'), logger: logger)
      end

      it 'logs a warning' do
        described_class.generate(input_path: input_path, output_path: output_path, logger: logger)

        expect(logger).to have_received(:warn).with(a_string_including('Falling back to a padded extent'))
      end
    end

    context 'when rasterization fails for an unrelated reason' do
      let(:unrelated_error) { GisRobotSuite::SystemCommandNonzeroExit.new('boom') }

      before do
        allow(GisRobotSuite).to receive(:run_system_command) do |command, **|
          raise unrelated_error if command.include?('rasterize')
        end
      end

      it 're-raises without retrying' do
        expect { described_class.generate(input_path: input_path, output_path: output_path, logger: logger) }
          .to raise_error(GisRobotSuite::SystemCommandNonzeroExit, 'boom')
      end
    end
  end
end
