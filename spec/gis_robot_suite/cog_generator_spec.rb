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

  def run(command) = GisRobotSuite.run_system_command(command, logger:)

  # Each band's value at a point given in EPSG:4326
  def values_at(path, lon, lat)
    run("gdallocationinfo -valonly -wgs84 #{Shellwords.escape(path.to_s)} #{lon} #{lat}")[:stdout_str].split.map(&:to_i)
  end

  def band_summary(path) = gdalinfo(path)['bands'].map { |band| [band['type'], band['colorInterpretation']] }

  context 'without a unit' do
    it 'creates a COG that records no band unit' do
      generate

      expect(output_path).to exist
      expect(gdalinfo(output_path)['bands'].first['unit']).to be_blank
    end

    # Computing min/max reads the whole raster, so it's kept for the few that could need it
    it "doesn't read the whole raster looking for 8-bit values in a Float32" do
      generate

      expect(GisRobotSuite).not_to have_received(:run_system_command).with(a_string_including('--min-max'), logger:)
    end
  end

  # Scanned maps ArcGIS saved as UInt16 with nothing but 0-255 in them, a NoData of 256 (outside the
  # Byte range) and bands labelled Gray/Undefined/Undefined. ogm-viewer stretches UInt16 over
  # 0-65535, so a COG that kept the type renders black.
  context 'when the raster holds only 8-bit values in UInt16' do
    let(:input_dir) { Pathname(Dir.mktmpdir) }
    let(:input_path) { input_dir / 'scan.tif' }
    let(:output_path) { output_dir / 'scan_cog.tif' }
    let(:band_count) { 3 }
    let(:burns) { [200, 150, 100] }
    # In the western half, where the scan has data; the eastern half is NoData
    let(:west) { [-122.475, 37.75] }
    let(:east) { [-122.425, 37.75] }

    before do
      run("gdal raster create --size 64,48 --ot UInt16 --band-count #{band_count} --nodata 256 --burn 256 " \
          "--bbox -122.5,37.7,-122.4,37.8 --crs EPSG:4326 #{input_path}")
      run("gdal raster create --size 32,48 --ot UInt16 --band-count #{band_count} #{burns.map { "--burn #{it}" }.join(' ')} " \
          "--bbox -122.5,37.7,-122.45,37.8 --crs EPSG:4326 #{input_dir / 'west.tif'}")
      run("gdalwarp -q #{input_dir / 'west.tif'} #{input_path}")
      FileUtils.rm_f(input_dir / 'west.tif')
    end

    after { FileUtils.rm_rf(input_dir) }

    it 'looks like the ArcGIS scans to begin with' do
      expect(band_summary(input_path)).to eq [%w[UInt16 Gray], %w[UInt16 Undefined], %w[UInt16 Undefined]]
      expect(gdalinfo(input_path)['bands'].first['noDataValue']).to eq 256
    end

    it 'creates a Byte RGB COG with the same values, and an alpha band where the master had NoData' do
      generate

      expect(band_summary(output_path)).to eq [%w[Byte Red], %w[Byte Green], %w[Byte Blue], %w[Byte Alpha]]
      expect(gdalinfo(output_path)['bands'].first['noDataValue']).to be_nil
      expect(values_at(output_path, *west)).to eq [200, 150, 100, 255]
      expect(values_at(output_path, *east).last).to eq 0
    end

    it 'leaves no VRT behind, and the master as it was' do
      digest_before = Digest::MD5.file(input_path).hexdigest

      generate

      expect(Dir.glob("#{output_dir}/*.vrt")).to be_empty
      expect(Digest::MD5.file(input_path).hexdigest).to eq digest_before
      # Computing statistics would have written an .aux.xml next to the master
      expect(input_dir.children.map { |child| child.basename.to_s }).to contain_exactly('scan.tif')
    end

    context 'with one band' do
      let(:band_count) { 1 }
      let(:burns) { [180] }

      it 'creates a Byte gray COG with an alpha band' do
        generate

        expect(band_summary(output_path)).to eq [%w[Byte Gray], %w[Byte Alpha]]
        expect(values_at(output_path, *west)).to eq [180, 255]
      end
    end

    context 'with values above 255' do
      let(:burns) { [200, 150, 1000] }

      it 'leaves genuine 16-bit data as it is' do
        generate

        expect(GisRobotSuite).not_to have_received(:run_system_command).with(a_string_including('gdal_translate'), logger:)
        expect(gdalinfo(output_path)['bands'].map { it['type'] }.uniq).to eq ['UInt16']
      end
    end

    context 'with a fourth band' do
      let(:band_count) { 4 }

      before do
        run("gdal_translate -q --config GDAL_PAM_ENABLED NO -colorinterp_4 #{fourth_band_label} #{input_path} #{input_dir / 'labelled.tif'}")
        FileUtils.mv(input_dir / 'labelled.tif', input_path)
      end

      context 'when it is labelled Alpha and spans all of UInt16' do
        let(:fourth_band_label) { 'alpha' }
        let(:burns) { [200, 150, 100, 65_535] }

        it 'scales the alpha band to Byte rather than clipping it' do
          generate

          expect(band_summary(output_path)).to eq [%w[Byte Red], %w[Byte Green], %w[Byte Blue], %w[Byte Alpha]]
          expect(values_at(output_path, *west)).to eq [200, 150, 100, 255]
        end
      end

      # How ArcGIS writes an RGB scan's transparency
      context 'when it is left Undefined' do
        let(:fourth_band_label) { 'undefined' }
        let(:burns) { [200, 150, 100, 255] }

        it 'takes it for the alpha band, and adds no other' do
          generate

          expect(band_summary(output_path)).to eq [%w[Byte Red], %w[Byte Green], %w[Byte Blue], %w[Byte Alpha]]
          expect(values_at(output_path, *west)).to eq [200, 150, 100, 255]
        end
      end
    end

    # A baseline TIFF has no GDAL NoData tag, so this one is all data: a NoData of 256 would
    # otherwise become a value above 255
    context 'when it declares no CRS of its own either' do
      let(:fallback_crs) { 'EPSG:4326' }

      before do
        run("gdal raster create --overwrite --size 64,48 --ot UInt16 --band-count 3 #{burns.map { "--burn #{it}" }.join(' ')} " \
            "--bbox -122.5,37.7,-122.4,37.8 --crs EPSG:4326 #{input_path}")
        run("gdal_translate -q --config GDAL_PAM_ENABLED NO -co PROFILE=BASELINE -co TFW=YES #{input_path} #{input_dir / 'tfw.tif'}")
        FileUtils.mv(input_dir / 'tfw.tif', input_path)
        FileUtils.mv(input_dir / 'tfw.tfw', input_dir / 'scan.tfw')
      end

      it 'assigns the fallback CRS and converts it to Byte' do
        expect(declared_crs(input_path)).to be_nil

        generate

        expect(GisRobotSuite).to have_received(:run_system_command).with(a_string_including('gdal raster edit --crs EPSG:4326'), logger:)
        # The COG driver adds an alpha band of its own when it reprojects a raster with no NoData
        expect(band_summary(output_path).first(3)).to eq [%w[Byte Red], %w[Byte Green], %w[Byte Blue]]
        expect(values_at(output_path, *west).first(3)).to eq [200, 150, 100]
        expect(wgs84_bounds(output_path)).to cover(-122.5, 37.7, -122.4, 37.8)
        expect(Dir.glob("#{output_dir}/*.vrt")).to be_empty
      end
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
