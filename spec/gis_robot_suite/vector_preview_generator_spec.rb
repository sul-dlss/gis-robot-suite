# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe GisRobotSuite::VectorPreviewGenerator do
  subject(:generate) { described_class.generate(input_path:, output_path:, logger:) }

  let(:logger) { instance_double(Logger, info: nil, warn: nil, debug: nil, error: nil) }
  let(:input_dir) { Pathname(Dir.mktmpdir) }
  let(:input_path) { input_dir / 'input.geojson' }
  let(:output_dir) { Pathname(Dir.mktmpdir) }
  let(:output_path) { output_dir / 'preview.jp2' }

  # Colors for testing how things render
  let(:water) { [212, 218, 220] }
  let(:land) { [250, 250, 248] }
  let(:fill) { [42, 134, 233] }
  let(:stacked_fill) { [8, 117, 235] }

  after do
    FileUtils.rm_rf(input_dir)
    FileUtils.rm_rf(output_dir)
  end

  # A GeoJSON layer in EPSG:4326 of the given geometries
  def write_geojson(*geometries)
    features = geometries.map { |geometry| { type: 'Feature', properties: {}, geometry: } }
    File.write(input_path, { type: 'FeatureCollection', features: }.to_json)
  end

  def square(xmin, ymin, xmax, ymax)
    { type: 'Polygon', coordinates: [[[xmin, ymin], [xmax, ymin], [xmax, ymax], [xmin, ymax], [xmin, ymin]]] }
  end

  def point(lon, lat) = { type: 'Point', coordinates: [lon, lat] }

  def gdalinfo(path)
    JSON.parse(GisRobotSuite.run_system_command("gdalinfo -json #{Shellwords.escape(path.to_s)}", logger:)[:stdout_str])
  end

  # The RGB color of one pixel of the thumbnail
  def pixel(column, row)
    command = "gdallocationinfo -valonly #{Shellwords.escape(output_path.to_s)} #{column} #{row}"
    GisRobotSuite.run_system_command(command, logger:)[:stdout_str].split.map(&:to_i)
  end

  def center = pixel(256, 256)

  # JP2 compression is lossy, so colors only need to be close
  def be_colored(rgb) = match(rgb.map { |channel| be_within(12).of(channel) })

  # Matches basemap colors (land or water)
  def be_basemap = satisfy('be land or water') { |rgb| [land, water].any? { |color| rgb.zip(color).all? { |a, b| (a - b).abs <= 12 } } }

  context 'with a polygon' do
    before { write_geojson(square(-1, -1, 1, 1)) }

    it 'creates a square RGB JP2' do
      generate

      info = gdalinfo(output_path)
      expect(info['size']).to eq [512, 512]
      expect(info['bands'].size).to eq 3
    end

    it 'fills the polygon in the viewer color, over the basemap' do
      generate

      expect(center).to be_colored(fill)
      expect(pixel(2, 2)).to be_colored(water)
    end

    it 'leaves no working files behind' do
      generate

      expect(output_dir.children.map { |child| child.basename.to_s }).to all(start_with('preview.jp2'))
    end
  end

  context 'with a polygon on land' do
    before { write_geojson(square(-99, 38, -98, 39)) }

    it 'draws it over the land' do
      generate

      expect(center).to be_colored(fill)
      expect(pixel(2, 2)).to be_colored(land)
    end
  end

  context 'with overlapping polygons, like index map sheets' do
    before { write_geojson(square(-1, -1, 1, 1), square(-1, -1, 1, 1)) }

    it 'stacks their fills the way the viewer does' do
      generate

      expect(center).to be_colored(stacked_fill)
    end
  end

  context 'with a line' do
    before { write_geojson({ type: 'LineString', coordinates: [[-1, 0], [1, 0]] }) }

    it 'draws it wide enough to see' do
      generate

      expect(center).to be_colored(fill)
      expect(pixel(256, 240)).to be_colored(water)
    end
  end

  context 'with a single point in a projected shapefile' do
    let(:input_path) { Pathname(fixture_dir) / 'workspace/bc/041/ny/0861/bc041ny0861/content/Pusan_CBD.shp' }

    it 'draws a dot in the middle, though the layer has no extent' do
      generate

      expect(center).to be_colored(fill)
      expect(pixel(256, 200)).to be_basemap
    end
  end

  context 'with a point beyond where Web Mercator reaches, like a station at the pole' do
    before { write_geojson(point(0, -90)) }

    it 'still draws it' do
      generate

      expect(center).to be_colored(fill)
    end
  end

  context 'with a polygon around the pole' do
    before { write_geojson(square(-180, 86, 180, 90)) }

    it 'draws it around the pole, rather than collapsing its long edges' do
      generate

      # Clear of the centre, where the polygon's own edge along ±180° meets the pole
      expect(pixel(256, 128)).to be_colored(fill)
      expect(pixel(384, 256)).to be_colored(fill)
    end
  end

  context 'with a polygon all the way round the globe, a hair past 180° as real data can be' do
    before { write_geojson(square(-180, -70, 180.000001, -60)) }

    it 'keeps the usual Mercator, which is the only one it draws whole in' do
      generate

      expect(center).to be_colored(fill)
      expect(pixel(60, 256)).to be_colored(fill)
    end
  end

  context 'with points either side of 180° longitude' do
    before { write_geojson(point(179.5, 0), point(180, 0), point(-179.5, 0)) }

    it 'centres the canvas on them rather than on the whole globe' do
      generate

      expect(center).to be_colored(fill)
    end
  end
end
