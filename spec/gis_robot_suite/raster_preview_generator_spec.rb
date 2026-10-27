# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe GisRobotSuite::RasterPreviewGenerator do
  subject(:generate) { described_class.generate(input_path:, output_path:, logger:) }

  let(:logger) { instance_double(Logger, info: nil, warn: nil, debug: nil, error: nil) }
  let(:input_dir) { Pathname(Dir.mktmpdir) }
  let(:input_path) { input_dir / 'input.tif' }
  let(:output_dir) { Pathname(Dir.mktmpdir) }
  let(:output_path) { output_dir / 'preview.jp2' }

  # Natural Earth's water, which these rasters sit over in the open ocean at 0°, 0°, and the start
  # and end of the viewer's viridis ramp
  let(:water) { [212, 218, 220] }
  let(:viridis_start) { [68, 1, 84] }
  let(:viridis_end) { [253, 231, 37] }

  after do
    FileUtils.rm_rf(input_dir)
    FileUtils.rm_rf(output_dir)
  end

  def run(command) = GisRobotSuite.run_system_command(command, logger:)[:stdout_str]

  # A single-band raster in EPSG:4326 with each box burned in its value, and nodata everywhere else
  def rasterize(boxes, extent:, size:, type: 'Float32', nodata: -9999, to: input_path)
    features = boxes.map do |(xmin, ymin, xmax, ymax), value|
      ring = [[xmin, ymin], [xmax, ymin], [xmax, ymax], [xmin, ymax], [xmin, ymin]]
      { type: 'Feature', properties: { value: }, geometry: { type: 'Polygon', coordinates: [ring] } }
    end
    File.write(input_dir / 'boxes.geojson', { type: 'FeatureCollection', features: }.to_json)
    run "gdal vector rasterize --overwrite --size #{size.join(',')} --extent #{extent.join(',')} --init #{nodata} " \
        "--nodata #{nodata} --attribute-name value --ot #{type} #{input_dir / 'boxes.geojson'} #{to}"
  end

  # The RGB color of one pixel of the thumbnail
  def pixel(column, row)
    run("gdallocationinfo -valonly #{Shellwords.escape(output_path.to_s)} #{column} #{row}").split.map(&:to_i)
  end

  def center = pixel(256, 256)

  # A color as the viewer draws it over the water, at its 0.8 opacity
  def over_water(rgb) = rgb.zip(water).map { |color, below| (color * 0.8) + (below * 0.2) }

  # JP2 compression is lossy, so colors only need to be close
  def be_colored(rgb) = match(rgb.map { |channel| be_within(12).of(channel) })

  context 'with red, green and blue bands' do
    before do
      run "gdal raster create --size 20,20 --bbox -1,-1,1,1 --crs EPSG:4326 --ot Byte --band-count 3 --burn 255 --burn 0 --burn 0 #{input_path}"
    end

    it 'creates a square RGB JP2' do
      generate

      info = JSON.parse(run("gdalinfo -json #{Shellwords.escape(output_path.to_s)}"))
      expect(info['size']).to eq [512, 512]
      expect(info['bands'].size).to eq 3
    end

    it 'draws them as they are, over the basemap' do
      generate

      expect(center).to be_colored(over_water([255, 0, 0]))
      expect(pixel(2, 2)).to be_colored(water)
    end

    it 'leaves no working files behind' do
      generate

      expect(output_dir.children.map { |child| child.basename.to_s }).to all(start_with('preview.jp2'))
    end
  end

  context 'with a single band of numbers' do
    before { rasterize({ [-1, -1, 0, 1] => 0, [0, -1, 1, 1] => 10 }, extent: [-1, -1, 1, 1], size: [20, 20]) }

    it 'draws them on the viewer ramp, stretched across their range' do
      generate

      expect(pixel(128, 256)).to be_colored(over_water(viridis_start))
      expect(pixel(384, 256)).to be_colored(over_water(viridis_end))
    end
  end

  context 'with nodata around the data' do
    before { rasterize({ [-1, -1, 1, 1] => 5 }, extent: [-5, -5, 5, 5], size: [50, 50]) }

    it 'fits the canvas to the data rather than the raster, and lets the basemap show through the nodata' do
      generate

      expect(pixel(100, 256)).to be_colored(over_water(viridis_start))
      expect(pixel(2, 2)).to be_colored(water)
    end
  end

  context 'with a palette' do
    let(:input_path) { input_dir / 'palette.vrt' }

    before do
      rasterize({ [-1, -1, 1, 1] => 2 }, extent: [-1, -1, 1, 1], size: [20, 20], type: 'Byte', nodata: 0, to: input_dir / 'index.tif')
      File.write(input_path, <<~XML)
        <VRTDataset rasterXSize="20" rasterYSize="20">
          <SRS>EPSG:4326</SRS>
          <GeoTransform>-1, 0.1, 0, 1, 0, -0.1</GeoTransform>
          <VRTRasterBand dataType="Byte" band="1">
            <NoDataValue>0</NoDataValue>
            <ColorInterp>Palette</ColorInterp>
            <ColorTable><Entry c1="0" c2="0" c3="0" c4="255"/><Entry c1="0" c2="0" c3="255" c4="255"/><Entry c1="0" c2="160" c3="0" c4="255"/></ColorTable>
            <SimpleSource><SourceFilename relativeToVRT="1">index.tif</SourceFilename><SourceBand>1</SourceBand></SimpleSource>
          </VRTRasterBand>
        </VRTDataset>
      XML
    end

    it 'draws it in its own colors' do
      generate

      expect(center).to be_colored(over_water([0, 160, 0]))
    end
  end

  context 'with a single band of bytes' do
    before { rasterize({ [-1, -1, 1, 1] => 40 }, extent: [-1, -1, 1, 1], size: [20, 20], type: 'Byte', nodata: 0) }

    it 'draws it in grey' do
      generate

      expect(center).to be_colored(over_water([40, 40, 40]))
    end
  end

  context 'with data either side of 180° longitude' do
    before { rasterize({ [-180, -1, -179, 1] => 5, [179, -1, 180, 1] => 5 }, extent: [-180, -10, 180, 10], size: [360, 20]) }

    it 'centres the canvas on it rather than on the whole globe' do
      generate

      expect(center).to be_colored(over_water(viridis_start))
    end
  end
end
