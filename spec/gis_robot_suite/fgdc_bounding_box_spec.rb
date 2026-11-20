# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::FgdcBoundingBox do
  let(:bounding_box) { GisRobotSuite::BoundingBox.new(west: 169.5207977294923, east: -143.0662994384765, north: 4.69949197769165, south: -17.852113723754883) }
  let(:workdir) { Dir.mktmpdir }
  let(:fgdc_file) { File.join(workdir, 'test-fgdc.xml') }
  let(:fgdc_ng) { Nokogiri::XML(File.read(fgdc_file)) }

  before do
    File.write(fgdc_file, source)
    described_class.apply(fgdc_file, bounding_box:)
  end

  after { FileUtils.rm_rf(workdir) }

  def bounding_coordinates
    fgdc_ng.at_xpath('/metadata/idinfo/spdom/bounding').element_children.to_h { |element| [element.name, element.text] }
  end

  context 'when the record states the extent ArcGIS recorded' do
    let(:source) { File.read(File.join(fixture_dir, 'stage/cc/044/gt/0726/cc044gt0726/content/sanluisobispo1996-fgdc.xml')) }

    it 'replaces it with the one computed from the data, west greater than east' do
      expect(bounding_coordinates).to include(
        'westbc' => '169.5207977294923', 'eastbc' => '-143.0662994384765', 'northbc' => '4.69949197769165', 'southbc' => '-17.852113723754883'
      )
      expect(fgdc_ng.xpath('//westbc').size).to eq 1
    end

    it 'keeps the bounds in CSDGM order' do
      expect(bounding_coordinates.keys.first(4)).to eq %w[westbc eastbc northbc southbc]
    end
  end

  context 'when the ArcGIS metadata had no extent to copy' do
    let(:source) { '<metadata><idinfo><citation/><descript/><status/><keywords/></idinfo></metadata>' }

    it 'adds a spatial domain after the status' do
      expect(fgdc_ng.at_xpath('/metadata/idinfo').element_children.map(&:name)).to eq %w[citation descript status spdom keywords]
      expect(bounding_coordinates.keys).to eq %w[westbc eastbc northbc southbc]
    end
  end
end
