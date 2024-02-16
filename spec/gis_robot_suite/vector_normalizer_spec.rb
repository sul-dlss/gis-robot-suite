# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::VectorNormalizer do
  let(:normalizer) { described_class.new(logger:, bare_druid:, rootdir:) }

  let(:bare_druid) { 'cc044gt0726' }

  let(:tmpdir) { '/tmp/normalizevector_cc044gt0726' }

  let(:wkt) do
    'GEOGCS["WGS 84", DATUM["WGS_1984", SPHEROID["WGS 84",6378137,298.257223563, AUTHORITY["EPSG","7030"]], AUTHORITY["EPSG","6326"]], PRIMEM["Greenwich",0, AUTHORITY["EPSG","8901"]], UNIT["degree",0.0174532925199433, AUTHORITY["EPSG","9122"]], AUTHORITY["EPSG","4326"]]' # rubocop:disable Layout/LineLength
  end

  let(:logger) { instance_double(Logger, debug: nil, info: nil) }

  let(:rootdir) { GisRobotSuite.locate_druid_path bare_druid, type: :workspace }

  before do
    FileUtils.mkdir_p(tmpdir)
    stub_request(:get, 'https://spatialreference.org/ref/epsg/4326/prettywkt/')
      .to_return(status: 200, body: wkt, headers: {})
    allow(Kernel).to receive(:system).and_call_original
  end

  after do
    normalizer.cleanup
  end

  describe '#normalize' do
    it 'creates a normalized PRJ file' do
      expect(normalizer.normalize).to eq(tmpdir)

      expect(File).to exist(File.join(tmpdir, 'sanluisobispo1996.prj'))
      expect(File).to exist(File.join(tmpdir, 'sanluisobispo1996.shp'))
      expect(File).to exist(File.join(tmpdir, 'sanluisobispo1996.dbf'))
      expect(File).to exist(File.join(tmpdir, 'sanluisobispo1996.shx'))

      expect(Kernel).to have_received(:system).with(
        "env SHAPE_ENCODING= ogr2ogr -progress -t_srs 'GEOGCS[\"WGS 84\", DATUM[\"WGS_1984\", SPHEROID[\"WGS 84\",6378137,298.257223563, AUTHORITY[\"EPSG\",\"7030\"]], AUTHORITY[\"EPSG\",\"6326\"]], PRIMEM[\"Greenwich\",0, AUTHORITY[\"EPSG\",\"8901\"]], UNIT[\"degree\",0.0174532925199433, AUTHORITY[\"EPSG\",\"9122\"]], AUTHORITY[\"EPSG\",\"4326\"]]' '/tmp/normalizevector_cc044gt0726/sanluisobispo1996.shp' 'spec/fixtures/workspace/cc/044/gt/0726/cc044gt0726/content/sanluisobispo1996.shp'", # rubocop:disable Layout/LineLength
        exception: true
      )
    end
  end
end
