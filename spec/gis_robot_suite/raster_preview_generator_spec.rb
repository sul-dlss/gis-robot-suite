# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::RasterPreviewGenerator do
  describe '.generate' do
    let(:input_path) { '/path/to/input.tif' }
    let(:output_path) { Pathname('/path/to/output.jp2') }
    let(:logger) { instance_double(Logger, info: nil, debug: nil) }
    let(:gdalinfo_result) { { stdout_str: { bands: [{ type: data_type }] }.to_json } }

    before do
      allow(GisRobotSuite).to receive(:run_system_command).and_return(gdalinfo_result)
    end

    context 'when the raster data type is compatible with JP2' do
      let(:data_type) { 'Byte' }

      it 'converts directly to JP2' do
        described_class.generate(input_path: input_path, output_path: output_path, logger: logger)

        expect(GisRobotSuite).to have_received(:run_system_command).with(
          "gdalinfo -json #{Shellwords.escape(input_path)}",
          logger: logger
        )
        expect(GisRobotSuite).to have_received(:run_system_command).with(
          "gdal convert --overwrite --co QUALITY=25 --co REVERSIBLE=NO #{Shellwords.escape(input_path)} #{Shellwords.escape(output_path.to_s)}",
          logger: logger
        )
      end
    end

    context 'when the raster is continuous data unsupported by JP2' do
      let(:data_type) { 'Float32' }
      let(:temp_tif_path) { '/path/to/output_temp.tif' }

      before do
        allow(FileUtils).to receive(:rm_f)
      end

      it 'scales to an Int16 intermediate before converting to JP2' do
        described_class.generate(input_path: input_path, output_path: output_path, logger: logger)

        expect(GisRobotSuite).to have_received(:run_system_command).with(
          "gdal raster scale --overwrite --ot Int16 #{Shellwords.escape(input_path)} #{Shellwords.escape(temp_tif_path)}",
          logger: logger
        )
        expect(GisRobotSuite).to have_received(:run_system_command).with(
          "gdal convert --overwrite --co QUALITY=25 --co REVERSIBLE=NO #{Shellwords.escape(temp_tif_path)} #{Shellwords.escape(output_path.to_s)}",
          logger: logger
        )
        expect(FileUtils).to have_received(:rm_f).with(Pathname(temp_tif_path))
      end
    end
  end
end
