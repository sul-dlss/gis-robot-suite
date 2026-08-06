# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::VectorDerivativeGenerator do
  describe '.generate' do
    let(:fgb_path) { Pathname.new('/path/to/output.fgb') }
    let(:pmtiles_path) { Pathname.new('/path/to/output.pmtiles') }
    let(:logger) { instance_double(Logger, info: nil, debug: nil) }

    before do
      allow(GisRobotSuite).to receive(:run_system_command)
    end

    context 'when the layer name starts with a digit' do
      let(:input_path) { Pathname.new('/path/to/22MUE250GC_SIR.shp') }

      it 'quotes the layer name as a SQL identifier' do
        described_class.generate(input_path: input_path, fgb_path: fgb_path, pmtiles_path: pmtiles_path, logger: logger)

        expect(GisRobotSuite).to have_received(:run_system_command).with(
          a_string_including('select * from "22MUE250GC_SIR" where geometry is not null'),
          logger: logger
        )
      end
    end

    context 'when the layer name does not start with a digit' do
      let(:input_path) { Pathname.new('/path/to/sanluisobispo1996.shp') }

      it 'still quotes the layer name as a SQL identifier' do
        described_class.generate(input_path: input_path, fgb_path: fgb_path, pmtiles_path: pmtiles_path, logger: logger)

        expect(GisRobotSuite).to have_received(:run_system_command).with(
          a_string_including('select * from "sanluisobispo1996" where geometry is not null'),
          logger: logger
        )
      end
    end
  end
end
