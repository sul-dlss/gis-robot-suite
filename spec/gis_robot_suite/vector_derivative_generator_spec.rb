# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::VectorDerivativeGenerator do
  subject(:generate) do
    described_class.generate(input_path: input_path, fgb_path: fgb_path, pmtiles_path: pmtiles_path,
                             fallback_crs: fallback_crs, logger: logger)
  end

  let(:logger) { instance_double(Logger, info: nil, warn: nil, debug: nil, error: nil) }
  let(:fallback_crs) { nil }

  describe 'tippecanoe maxzoom handling' do
    let(:input_path) { Pathname.new('/path/to/layer.shp') }
    let(:fgb_path) { Pathname.new('/path/to/output.fgb') }
    let(:pmtiles_path) { Pathname.new('/path/to/output.pmtiles') }

    # `gdal vector info` for a layer that declares its own CRS, so the generator needs no
    # -s_srs and the commands under test here are just the ogr2ogr and tippecanoe ones.
    let(:vector_info) do
      {
        stdout_str: {
          layers: [{ geometryFields: [{ coordinateSystem: { projjson: { id: { authority: 'EPSG', code: 26_910 } } } }] }]
        }.to_json
      }
    end

    context 'when tippecanoe can guess a maxzoom' do
      before do
        allow(GisRobotSuite).to receive(:run_system_command) do |command, **|
          vector_info if command.include?('gdal vector info')
        end
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
          next vector_info if command.include?('gdal vector info')

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
          next vector_info if command.include?('gdal vector info')

          raise unrelated_error if command.include?('tippecanoe')
        end
      end

      it 're-raises without retrying' do
        expect { generate }.to raise_error(GisRobotSuite::SystemCommandNonzeroExit, 'boom')
        expect(GisRobotSuite).to have_received(:run_system_command).with(a_string_including('tippecanoe'), logger: logger).once
      end
    end
  end

  describe 'source projection' do
    let(:tmpdir) { Dir.mktmpdir('vector_derivative_generator') }
    let(:fgb_path) { Pathname.new(File.join(tmpdir, 'output.fgb')) }
    let(:pmtiles_path) { Pathname.new(File.join(tmpdir, 'output.pmtiles')) }

    before do
      allow(GisRobotSuite).to receive(:run_system_command).and_call_original
    end

    after do
      FileUtils.remove_entry(tmpdir)
    end

    context 'when the shapefile declares its own projection' do
      let(:input_path) { Pathname.new('spec/fixtures/workspace/cc/044/gt/0726/cc044gt0726/content/sanluisobispo1996.shp') }
      let(:fallback_crs) { 'EPSG:3309' }

      it 'lets GDAL read the projection from the .prj rather than overriding it' do
        generate

        expect(GisRobotSuite).not_to have_received(:run_system_command).with(a_string_including('-s_srs'), logger: logger)
        expect(File).to exist(fgb_path)
      end
    end

    context 'when the shapefile has no .prj' do
      let(:input_path) { Pathname.new('spec/fixtures/workspace/cf/920/rt/3856/cf920rt3856/content/Pusan_CBD.shp') }
      let(:fallback_crs) { 'EPSG:32652' }

      it 'reprojects using the projection that was supplied' do
        generate

        expect(GisRobotSuite).to have_received(:run_system_command).with(a_string_including('-s_srs EPSG:32652'), logger: logger)
        expect(File).to exist(fgb_path)
      end
    end

    context 'when the shapefile has no .prj and no fallback projection was supplied' do
      let(:input_path) { Pathname.new('spec/fixtures/workspace/cf/920/rt/3856/cf920rt3856/content/Pusan_CBD.shp') }
      let(:fallback_crs) { nil }

      it 'raises rather than handing ogr2ogr a reprojection it cannot perform' do
        expect { generate }.to raise_error(
          described_class::MissingSourceCrs,
          /Pusan_CBD\.shp has no spatial reference system and no map projection was supplied to fall back on/
        )
      end
    end
  end
end
