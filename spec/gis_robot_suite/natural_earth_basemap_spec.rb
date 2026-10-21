# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe GisRobotSuite::NaturalEarthBasemap do
  subject(:render) { described_class.render(output_path:, extent:, crs:, size: 64, central_meridian:, logger:) }

  let(:logger) { instance_double(Logger, info: nil, warn: nil, debug: nil, error: nil) }
  let(:output_dir) { Pathname(Dir.mktmpdir) }
  let(:output_path) { output_dir / 'basemap.tif' }
  let(:crs) { 'EPSG:3857' }
  let(:central_meridian) { 0 }

  let(:water) { [212, 218, 220] }
  let(:land) { [250, 250, 248] }

  after { FileUtils.rm_rf(output_dir) }

  # A canvas 100 km square around a point, in Web Mercator metres
  def around(lon, lat, half_side: 50_000)
    radius = described_class::EARTH_RADIUS
    x = radius * lon * Math::PI / 180
    y = radius * Math.log(Math.tan((Math::PI / 4) + (lat * Math::PI / 360)))
    [x - half_side, y - half_side, x + half_side, y + half_side]
  end

  # The RGB color of one pixel of the basemap, which is a lossless GeoTIFF
  def pixel(column, row)
    command = "gdallocationinfo -valonly #{Shellwords.escape(output_path.to_s)} #{column} #{row}"
    GisRobotSuite.run_system_command(command, logger:)[:stdout_str].split.map(&:to_i)
  end

  context 'with a canvas over the middle of Kansas' do
    let(:extent) { around(-98.5, 38.5) }

    it 'draws land' do
      render

      expect(pixel(32, 32)).to eq land
    end
  end

  context 'with a canvas over the open Pacific' do
    let(:extent) { around(-150, -10) }

    it 'draws water' do
      render

      expect(pixel(32, 32)).to eq water
    end
  end

  context 'with a canvas across 180°, in a Mercator flipped to centre on it' do
    let(:crs) { '+proj=merc +a=6378137 +b=6378137 +lon_0=180 +x_0=0 +y_0=0 +k=1 +units=m +no_defs' }
    let(:central_meridian) { 180 }
    # 6,000 km square over the Bering Strait, centred on 65°N
    let(:extent) do
      y = described_class::EARTH_RADIUS * Math.log(Math.tan((Math::PI / 4) + (65 * Math::PI / 360)))
      [-3_000_000, y - 3_000_000, 3_000_000, y + 3_000_000]
    end

    it 'draws the land on both sides of it' do
      render

      expect(pixel(20, 32)).to eq land # Chukotka, at 170°E
      expect(pixel(61, 32)).to eq land # Alaska, at 155°W
    end
  end

  context 'with a canvas round the south pole, in polar stereographic' do
    let(:crs) { 'EPSG:3031' }
    let(:extent) { [-50_000, -50_000, 50_000, 50_000] }

    it 'draws the land at the pole' do
      render

      expect(pixel(32, 32)).to eq land
    end
  end
end
