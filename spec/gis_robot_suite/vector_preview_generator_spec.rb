# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::VectorPreviewGenerator do
  describe '.generate' do
    let(:input_path) { Pathname.new('/path/to/input.shp') }
    let(:output_path) { Pathname.new('/path/to/output.jp2') }
    let(:temp_tif_path) { Pathname.new('/path/to/output_temp.tif') }
    let(:logger) { instance_double(Logger, info: nil, debug: nil) }

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
        "gdal convert #{Shellwords.escape(temp_tif_path.to_s)} #{Shellwords.escape(output_path.to_s)}",
        logger: logger
      )

      expect(FileUtils).to have_received(:rm_f).with(temp_tif_path)
    end
  end
end
