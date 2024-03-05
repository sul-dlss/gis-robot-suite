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

  describe '#run_shp2pgsql' do
    let(:projection) { '4326' }
    let(:encoding) { 'UTF-8' }
    let(:bare_druid) { 'cc044gt0726' }
    let(:shp_filename) { "#{tmpdir}/sanluisobispo1996.shp" }
    let(:sql_filename) { "#{tmpdir}/sanluisobispo1996.sql" }
    let(:stderr_filename) { "#{tmpdir}/shp2pgsql.err" }
    let(:cmd) { "shp2pgsql -s #{projection} -d -D -I -W #{encoding} '#{shp_filename}' druid.#{bare_druid} > '#{sql_filename}' 2> '#{stderr_filename}'" }

    before do
      allow(normalizer).to receive(:system).with(cmd, exception: true).and_return(true)
      allow(File).to receive(:size?).with(sql_filename).and_return('123')
    end

    it 'runs the psql command with the given parameters' do
      normalizer.run_shp2pgsql(projection, encoding, shp_filename, 'druid', sql_filename, stderr_filename)
      expect(normalizer).to have_received(:system).with(cmd, exception: true)
    end
  end
end
