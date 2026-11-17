# frozen_string_literal: true

require 'spec_helper'
require 'digest'
require 'tmpdir'

RSpec.describe GisRobotSuite::CogGenerator do
  subject(:generate) { described_class.generate(input_path:, output_path:, unit:, fallback_crs:, logger:) }

  let(:logger) { instance_double(Logger, info: nil, warn: nil, debug: nil, error: nil) }
  let(:unit) { nil }
  let(:fallback_crs) { nil }
  let(:output_dir) { Pathname(Dir.mktmpdir) }
  let(:output_path) { output_dir / 'MONT_DEM_cog.tif' }
  # A Float32 raster, so an unrecorded band unit is a real gap rather than a categorical code.
  let(:input_path) do
    Pathname(fixture_dir) / 'workspace/sf/815/vr/1246/sf815vr1246/content/MONT_DEM.tif'
  end

  after { FileUtils.rm_rf(output_dir) }

  before do
    allow(GisRobotSuite).to receive(:run_system_command).and_call_original
  end

  def gdalinfo(path)
    JSON.parse(GisRobotSuite.run_system_command("gdalinfo -json #{Shellwords.escape(path.to_s)}", logger:)[:stdout_str])
  end

  # Where a raster sits, as [west, south, east, north] in EPSG:4326
  def wgs84_bounds(path)
    lons, lats = gdalinfo(path)['wgs84Extent']['coordinates'].first.transpose
    [lons.min, lats.min, lons.max, lats.max]
  end

  # A GoogleMapsCompatible COG snaps its extent out to whole tiles, so it covers where the source
  # sits, give or take a tile
  def cover(west, south, east, north)
    satisfy('cover the source, give or take a tile') do |cog_west, cog_south, cog_east, cog_north|
      [cog_west <= west, cog_south <= south, cog_east >= east, cog_north >= north].all? &&
        [west - cog_west, south - cog_south, cog_east - east, cog_north - north].all? { |gap| gap < 2 }
    end
  end

  def declared_crs(path) = gdalinfo(path).dig('stac', 'proj:projjson')

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

  context 'when the raster declares its own CRS' do
    let(:fallback_crs) { 'EPSG:26910' }

    it 'converts it as it is, ignoring the fallback' do
      generate

      expect(GisRobotSuite).not_to have_received(:run_system_command).with(a_string_including('gdal raster edit'), logger:)
      expect(GisRobotSuite).not_to have_received(:run_system_command).with(a_string_including('VRT'), logger:)
      expect(wgs84_bounds(output_path)).to cover(*wgs84_bounds(input_path))
    end
  end

  # Georeferenced by nothing but a .tfw world file in degrees, as many legacy GeoTIFFs are: GDAL
  # finds no CRS, so a GoogleMapsCompatible COG would take the degrees for EPSG:3857 metres and
  # fail with "Could not find an appropriate zoom level".
  context 'when the raster declares no CRS of its own' do
    let(:input_dir) { Pathname(Dir.mktmpdir) }
    let(:input_path) { input_dir / 'sidescan.tif' }
    let(:bounds) { [-122.2332, 36.8203, -122.2240, 36.8253] }

    before do
      GisRobotSuite.run_system_command(
        "gdal raster create --size 200,140 --ot Byte --burn 7 --bbox #{bounds.join(',')} --crs EPSG:4326 #{input_dir / 'georeferenced.tif'}", logger:
      )
      GisRobotSuite.run_system_command(
        "gdal_translate -q --config GDAL_PAM_ENABLED NO -co PROFILE=BASELINE -co TFW=YES #{input_dir / 'georeferenced.tif'} #{input_path}", logger:
      )
      FileUtils.rm_f(input_dir / 'georeferenced.tif')
    end

    after { FileUtils.rm_rf(input_dir) }

    it 'has no CRS to begin with' do
      expect(declared_crs(input_path)).to be_nil
      expect(input_dir / 'sidescan.tfw').to exist
    end

    context 'with a fallback CRS' do
      let(:fallback_crs) { 'EPSG:4326' }

      it 'creates a COG where the fallback CRS puts it' do
        generate

        expect(GisRobotSuite).to have_received(:run_system_command).with(a_string_including('gdal raster edit --crs EPSG:4326'), logger:)
        expect(declared_crs(output_path)['id']).to eq('authority' => 'EPSG', 'code' => 3857)
        expect(wgs84_bounds(output_path)).to cover(*bounds)
      end

      it 'leaves no VRT behind' do
        generate

        expect(Dir.glob("#{output_dir}/*.vrt")).to be_empty
      end

      it 'does not modify the master' do
        digest_before = Digest::MD5.file(input_path).hexdigest

        generate

        expect(Digest::MD5.file(input_path).hexdigest).to eq digest_before
        expect(input_dir.children.map { |child| child.basename.to_s }).to contain_exactly('sidescan.tif', 'sidescan.tfw')
      end

      context 'with a unit too' do
        let(:unit) { 'm' }

        before do
          GisRobotSuite.run_system_command(
            "gdal raster create --overwrite --size 200,140 --ot Float32 --nodata -9999 --burn 7 --bbox #{bounds.join(',')} #{input_path}", logger:
          )
        end

        it 'creates a COG that records both' do
          generate

          expect(gdalinfo(output_path)['bands'].first['unit']).to eq 'm'
          expect(wgs84_bounds(output_path)).to cover(*bounds)
          expect(Dir.glob("#{output_dir}/*.vrt")).to be_empty
        end
      end
    end

    context 'without a fallback CRS' do
      it 'raises, naming the file, rather than letting GDAL fail to find a zoom level' do
        expect { generate }.to raise_error(GisRobotSuite::RasterSourceCrs::MissingSourceCrs,
                                           "#{input_path} has no usable spatial reference system " \
                                           'and no map projection was supplied to fall back on')
        expect(output_path).not_to exist
      end
    end

    context 'with a fallback CRS GDAL does not recognize' do
      let(:fallback_crs) { 'EPSGEPSG:432626910' }

      it 'raises, naming the file and the fallback' do
        expect { generate }.to raise_error(GisRobotSuite::RasterSourceCrs::MissingSourceCrs,
                                           /\A#{Regexp.escape(input_path.to_s)} has no usable .* EPSGEPSG:432626910\z/)
        expect(output_path).not_to exist
      end
    end
  end

  context 'when the raster declares an engineering CRS' do
    let(:input_path) { Pathname(fixture_dir) / 'workspace/mk/892/hd/7761/mk892hd7761/content/artisanal.tif' }
    let(:output_path) { output_dir / 'artisanal_cog.tif' }
    let(:fallback_crs) { 'ESRI:54009' }

    it 'creates a COG from the fallback CRS instead' do
      generate

      expect(GisRobotSuite).to have_received(:run_system_command).with(a_string_including('gdal raster edit --crs ESRI:54009'), logger:)
      expect(declared_crs(output_path)['id']).to eq('authority' => 'EPSG', 'code' => 3857)
    end
  end
end
