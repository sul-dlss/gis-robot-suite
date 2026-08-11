# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::VectorNormalizer do
  let(:normalizer) { described_class.new(logger:, cocina_object:, rootdir:) }

  let(:druid) { "druid:#{bare_druid}" }

  let(:tmpdir) { "/tmp/normalizevector_#{bare_druid}" }

  let(:cocina_object) { build(:dro, id: druid).new(description:) }

  let(:description) do
    {
      title: [{ value: 'Test vector data' }],
      form: [{ value: map_projection, type: 'map projection' }].compact,
      geographic: [
        {
          form: [
            { value: 'application/vnd.shp', type: 'media type', source: { value: 'IANA media type terms' } },
            { value: 'Shapefile', type: 'data format' }
          ]
        }
      ],
      purl: "https://purl.stanford.edu/#{bare_druid}"
    }
  end

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
    context 'when the shapefile declares its own projection' do
      let(:bare_druid) { 'cc044gt0726' }
      let(:map_projection) { 'EPSG::3309' }

      it 'reprojects it, letting GDAL read the source projection from the .prj' do
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

    context 'when the shapefile has no .prj' do
      let(:bare_druid) { 'cf920rt3856' }
      let(:map_projection) { 'EPSG::32652' }

      it 'reprojects it using the projection cocina recorded' do
        expect(normalizer.normalize).to eq(tmpdir)

        expect(File).to exist(File.join(tmpdir, 'Pusan_CBD.prj'))
        expect(File).to exist(File.join(tmpdir, 'Pusan_CBD.shp'))

        expect(GisRobotSuite).to have_received(:run_system_command).with(
          'env SHAPE_ENCODING= gdal vector reproject --src-crs=EPSG:32652 --dst-crs=EPSG:4326 --overwrite ' \
          "'spec/fixtures/workspace/cf/920/rt/3856/cf920rt3856/content/Pusan_CBD.shp' '/tmp/normalizevector_cf920rt3856/Pusan_CBD.shp'",
          logger:
        )
      end
    end

    context 'when the shapefile has no .prj and cocina records no usable map projection' do
      let(:bare_druid) { 'cf920rt3856' }
      let(:map_projection) { 'World_Mollweide' } # a name, not an authority and code

      it 'raises' do
        expect { normalizer.normalize }.to raise_error(
          'normalize-vector: cf920rt3856 Pusan_CBD has no spatial reference system ' \
          'and cocina records no map projection to fall back on'
        )
      end
    end

    context 'when the shapefile is already in EPSG:4326' do
      let(:bare_druid) { 'cz128vq0535' }
      let(:map_projection) { 'EPSG::4326' }
      let(:source_filepath) { 'spec/fixtures/workspace/cz/128/vq/0535/cz128vq0535/content/Ug_Rural_Poverty2005.shp' }

      it 'links the data rather than reprojecting it' do
        expect(normalizer.normalize).to eq(tmpdir)

        expect(File).to exist(File.join(tmpdir, 'Ug_Rural_Poverty2005.shp'))
        expect(File).to exist(File.join(tmpdir, 'Ug_Rural_Poverty2005.dbf'))
        expect(File).to exist(File.join(tmpdir, 'Ug_Rural_Poverty2005.shx'))

        expect(GisRobotSuite).not_to have_received(:run_system_command).with(
          a_string_including('gdal vector reproject'), logger:
        )
      end

      it 'leaves the source data in place when cleaning up' do
        normalizer.normalize
        normalizer.cleanup

        expect(File).to exist(source_filepath)
      end
    end

    context 'when the shapefile has no .prj but cocina says it is already in EPSG:4326' do
      let(:bare_druid) { 'dw283hn4419' }
      let(:map_projection) { 'EPSG::4326' }

      it 'links the data rather than reprojecting it' do
        expect(normalizer.normalize).to eq(tmpdir)

        expect(File).to exist(File.join(tmpdir, 'Pusan_CBD.shp'))

        expect(GisRobotSuite).not_to have_received(:run_system_command).with(
          a_string_including('gdal vector reproject'), logger:
        )
      end
    end
  end
end
