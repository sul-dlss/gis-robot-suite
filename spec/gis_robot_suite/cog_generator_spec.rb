# frozen_string_literal: true

require 'spec_helper'
require 'digest'
require 'tmpdir'

RSpec.describe GisRobotSuite::CogGenerator do
  subject(:generate) { described_class.generate(input_path:, output_path:, unit:, logger:) }

  let(:logger) { instance_double(Logger, info: nil, warn: nil, debug: nil, error: nil) }
  let(:unit) { nil }
  let(:output_dir) { Pathname(Dir.mktmpdir) }
  let(:output_path) { output_dir / 'MONT_DEM_cog.tif' }
  # A Float32 raster, so an unrecorded band unit is a real gap rather than a categorical code.
  let(:input_path) do
    Pathname(fixture_dir) / 'workspace/sf/815/vr/1246/sf815vr1246/content/MONT_DEM.tif'
  end

  after { FileUtils.rm_rf(output_dir) }

  def gdalinfo(path)
    JSON.parse(GisRobotSuite.run_system_command("gdalinfo -json #{Shellwords.escape(path.to_s)}", logger:)[:stdout_str])
  end

  context 'without a unit' do
    it 'creates a COG that records no band unit' do
      generate

      expect(output_path).to exist
      expect(gdalinfo(output_path)['bands'].first['unit']).to be_blank
    end
  end

  context 'with a unit' do
    let(:unit) { 'm' }

    it 'creates a COG that records the unit against the band' do
      generate

      expect(gdalinfo(output_path)['bands'].first['unit']).to eq 'm'
    end

    it 'keeps the source data type' do
      generate

      expect(gdalinfo(output_path)['bands'].first['type']).to eq 'Float32'
    end

    # The unit is carried in on a VRT wrapper, which is a working file and must not be left
    # for accessioning to pick up.
    it 'leaves no VRT behind' do
      generate

      expect(Dir.glob("#{output_dir}/*.vrt")).to be_empty
    end

    # Editing the master would invalidate the checksums cocina recorded during assembly.
    it 'does not modify the master' do
      digest_before = Digest::MD5.file(input_path).hexdigest

      generate

      expect(Digest::MD5.file(input_path).hexdigest).to eq digest_before
      expect(gdalinfo(input_path)['bands'].first['unit']).to be_blank
    end

    context 'when the conversion fails' do
      let(:output_path) { output_dir / 'no-such-subdirectory' / 'MONT_DEM_cog.tif' }

      it 'still cleans up the VRT' do
        expect { generate }.to raise_error(GisRobotSuite::SystemCommandNonzeroExit)
        expect(Dir.glob("#{output_dir}/**/*.vrt")).to be_empty
      end
    end
  end
end
