# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::VectorNormalizer do
  let(:normalizer) { described_class.new(logger:, bare_druid:, rootdir:) }

  let(:bare_druid) { 'cc044gt0726' }

  let(:tmpdir) { '/tmp/normalizevector_cc044gt0726' }

  let(:logger) { instance_double(Logger, debug: nil, info: nil) }

  let(:rootdir) { GisRobotSuite.locate_druid_path bare_druid, type: :workspace }

  before do
    FileUtils.mkdir_p(tmpdir)

    allow(GisRobotSuite).to receive(:run_system_command).and_call_original
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

      expect(GisRobotSuite).to have_received(:run_system_command).with(
        'env SHAPE_ENCODING= gdal vector reproject --dst-crs=EPSG:4326 --overwrite ' \
        "'spec/fixtures/workspace/cc/044/gt/0726/cc044gt0726/content/sanluisobispo1996.shp' '/tmp/normalizevector_cc044gt0726/sanluisobispo1996.shp'",
        logger:
      )
    end
  end
end
