# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::RasterPreviewGenerator do
  describe '.generate' do
    let(:input_path) { '/path/to/input.tif' }
    let(:output_path) { '/path/to/output.jp2' }
    let(:logger) { instance_double(Logger, info: nil, debug: nil) }

    before do
      allow(GisRobotSuite).to receive(:run_system_command)
    end

    it 'executes the correct gdal convert command' do
      described_class.generate(input_path: input_path, output_path: output_path, logger: logger)

      expect(GisRobotSuite).to have_received(:run_system_command).with(
        "gdal convert #{Shellwords.escape(input_path)} #{Shellwords.escape(output_path)}",
        logger: logger
      )
    end
  end
end
