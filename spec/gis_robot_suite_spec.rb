# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite do
  let(:cocina_object) do
    dro = build(:dro)
    dro.new(description: dro.description.new(geographic: [
                                               { form: [{ type: 'media type', value: media_type }, { type: 'data format', value: data_format }] }
                                             ]))
  end
  let(:media_type) { 'image/tiff ' }
  let(:data_format) { 'GeoTIFF' }

  describe '.media_type' do
    it 'returns media type' do
      expect(described_class.media_type(cocina_object)).to eq(media_type)
    end
  end

  describe '.data_format' do
    it 'returns data format' do
      expect(described_class.data_format(cocina_object)).to eq(data_format)
    end
  end

  describe '.vector?' do
    context 'when a vector' do
      let(:media_type) { 'application/x-esri-shapefile' }

      it 'returns true' do
        expect(described_class).to be_vector(cocina_object)
      end
    end

    context 'when not a vector' do
      let(:media_type) { 'image/tiff' }

      it 'returns false' do
        expect(described_class).not_to be_vector(cocina_object)
      end
    end
  end

  describe '.raster?' do
    context 'when a raster' do
      let(:media_type) { 'image/tiff' }

      it 'returns true' do
        expect(described_class).to be_raster(cocina_object)
      end
    end

    context 'when not a raster' do
      let(:media_type) { 'application/x-esri-shapefile' }

      it 'returns false' do
        expect(described_class).not_to be_raster(cocina_object)
      end
    end

    context 'when an ArcGrid raster' do
      let(:media_type) { 'application/x-ogc-aig' }

      it 'raises' do
        expect { described_class.raster?(cocina_object) }.to raise_error(RuntimeError, "druid:bc234fg5678 is ArcGrid format: 'application/x-ogc-aig'")
      end
    end
  end

  describe '.determine_rights' do
    subject { described_class.determine_rights(cocina_object) }

    let(:cocina_object) { build(:dro).new(access: { view: access, download: access }) }

    context 'when public' do
      let(:access) { 'world' }

      it { is_expected.to eq 'public' }
    end

    context 'when restricted' do
      let(:access) { 'stanford' }

      it { is_expected.to eq 'restricted' }
    end
  end

  describe '.layertype' do
    let(:cocina_object) do
      dro = build(:dro)
      dro.new(description: dro.description.new(geographic: [
                                                 { form: [{ type: 'media type', value: media_type }, { type: 'data format', value: data_format }] }
                                               ]))
    end

    context 'when an unknown media type' do
      let(:media_type) { 'something/else' }

      it 'raises' do
        expect { described_class.layertype(cocina_object) }.to raise_error(RuntimeError, 'druid:bc234fg5678 has unknown format: something/else')
      end
    end

    context 'when a vector' do
      let(:media_type) { 'application/x-esri-shapefile' }

      it 'has layertype PostGIS' do
        expect(described_class.layertype(cocina_object)).to eq 'PostGIS'
      end
    end

    context 'when a raster' do
      let(:media_type) { 'image/tiff' }

      it 'has layertype GeoTIFF' do
        expect(described_class.layertype(cocina_object)).to eq 'GeoTIFF'
      end
    end
  end

  describe '.determine_raster_style' do
    let(:rgb8_file) { File.join(fixture_dir, 'tif_files/MCE_AF2G_2010.tif') }
    let(:grayscale8_file) { File.join(fixture_dir, 'stage/bh/432/xr/2264/bh432xr2264/content/51002.tif') }
    let(:logger) { instance_double(Logger, info: nil, debug: nil) }

    after do
      # the *.aux.xml files are written by gdalinfo when it computes image statistics (will be regenerated if not present)
      FileUtils.rm_rf("#{rgb8_file}.aux.xml")
      FileUtils.rm_rf("#{grayscale8_file}.aux.xml")
    end

    it 'determines the correct raster style' do
      expect(described_class.determine_raster_style(rgb8_file, logger:)).to eq('rgb8')
      expect(described_class.determine_raster_style(grayscale8_file, logger:)).to eq('grayscale8')
    end
  end

  describe '.locate_druid_path' do
    let(:druid) { 'druid:bc123df4567' }

    context 'when type is :stage' do
      it 'returns the stage path' do
        expect(described_class.locate_druid_path(druid, type: :stage)).to eq File.join(Settings.geohydra.stage, 'bc', '123', 'df', '4567', 'bc123df4567')
      end
    end

    context 'when type is :workspace' do
      it 'returns the workspace path' do
        expect(described_class.locate_druid_path(druid, type: :workspace)).to eq DruidTools::Druid.new(druid, Settings.geohydra.workspace).path
      end
    end

    context 'when type is not :stage or :workspace' do
      it 'raises' do
        expect { described_class.locate_druid_path(druid, type: :something_else) }.to raise_error(RuntimeError, 'Only :stage, :workspace are supported')
      end
    end

    context 'when validate is true and the directory does not exist' do
      it 'raises' do
        expect { described_class.locate_druid_path(druid, type: :stage, validate: true) }.to raise_error(RuntimeError, "Missing #{Settings.geohydra.stage}/bc/123/df/4567/bc123df4567")
      end
    end
  end

  describe '.run_system_command' do
    let(:cmd_result) { described_class.run_system_command(cmd, logger:) }

    let(:logger) { instance_double(Logger, debug: nil, info: nil, error: nil) }

    context 'when the command succeeds' do
      let(:cmd) { 'echo "hello"' }
      let(:expected_result) { { cmd:, stdout_str: "hello\n", stderr_str: '', exitstatus: 0, success: true } }

      it 'does not raise' do
        expect { cmd_result }.not_to raise_error
      end

      it 'returns a hash with the result of the command execution' do
        expect(cmd_result).to eq(expected_result)
      end

      it 'logs beginning and succeeding' do
        cmd_result
        expect(logger).to have_received(:info).with("#{described_class}.run_system_command: Attempting to execute system command: '#{cmd}'")
        expect(logger).to have_received(:info).with("#{described_class}.run_system_command: Successfully executed system command: '#{cmd}'")
        expect(logger).to have_received(:debug).with("#{described_class}.run_system_command: System command result: #{cmd_result}")
      end
    end

    context 'when the command finishes and returns a non-zero error code' do
      let(:cmd) { 'cat missing_file' }
      let(:expected_result) { { cmd:, stdout_str: '', stderr_str: "cat: missing_file: No such file or directory\n", exitstatus: 1, success: false } }
      let(:err_msg) { "Unsuccessful attempt executing system command: result=#{expected_result}" }

      it 'raises an informative error' do
        expect { cmd_result }.to raise_error(described_class::SystemCommandNonzeroExit, err_msg)
      end

      it 'logs beginning and failing' do
        expect { cmd_result }.to raise_error(described_class::SystemCommandError)
        expect(logger).to have_received(:info).with("#{described_class}.run_system_command: Attempting to execute system command: '#{cmd}'")
        expect(logger).to have_received(:error).with("#{described_class}.run_system_command: #{err_msg}")
      end
    end

    context 'when the command fails to run and exit on its own' do
      let(:cmd) { 'ssshh' }
      let(:err_msg) { "Error executing system command: '#{cmd}' raised No such file or directory - ssshh" }

      it 'raises an informative error' do
        expect { cmd_result }.to raise_error(
          an_instance_of(described_class::SystemCommandExecutionError).and(
            having_attributes(message: err_msg, cause: a_kind_of(Errno::ENOENT))
          )
        )
      end

      it 'logs beginning and erroring out' do
        expect { cmd_result }.to raise_error(described_class::SystemCommandError)
        expect(logger).to have_received(:info).with("#{described_class}.run_system_command: Attempting to execute system command: '#{cmd}'")
        expect(logger).to have_received(:error).with("#{described_class}.run_system_command: #{err_msg}")
      end
    end
  end
end
