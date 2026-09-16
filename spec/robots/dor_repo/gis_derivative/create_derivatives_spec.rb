# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe Robots::DorRepo::GisDerivative::CreateDerivatives do
  subject(:perform) { test_perform(robot, druid) }

  let(:bare_druid) { druid.delete_prefix('druid:') }
  let(:robot) { described_class.new }
  let(:cocina_object) { build(:dro, id: druid).new(structural: structural, access: { view: 'world' }) }
  let(:object_client) do
    instance_double(Dor::Services::Client::Object, find: cocina_object, update: true)
  end
  let(:workspace_path) { Pathname.new(Settings.geohydra.workspace) / bare_druid[0..1] / bare_druid[2..4] / bare_druid[5..6] / bare_druid[7..] / bare_druid / 'content' }
  let(:structural) { Cocina::Models::DROStructural.new({ contains: [fileset] }) }
  let(:fileset) do
    Cocina::Models::FileSet.new(
      type: 'https://cocina.sul.stanford.edu/models/resources/object',
      externalIdentifier: "https://cocina.sul.stanford.edu/fileSet/#{bare_druid}-#{bare_druid}_1",
      label: 'Data',
      version: 2,
      structural: { contains: files }
    )
  end
  let(:files) { [master_file] }
  let(:jp2_file_path) { workspace_path / "#{layer_name}.jp2" }
  let(:logger) { instance_double(Logger, info: nil, warn: nil, error: nil, debug: nil) }
  let(:esri_metadata_present) { true }

  before do
    allow(robot).to receive_messages(druid: druid, logger: logger)
    allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    allow(GisRobotSuite).to receive(:locate_druid_path).and_return(workspace_path.parent)
    allow(GisRobotSuite).to receive(:locate_esri_metadata).and_raise('Missing ESRI metadata files') unless esri_metadata_present
    perform
  end

  after do
    FileUtils.rm_f(jp2_file_path)
    FileUtils.rm_f(jp2_file_path.sub_ext('.jp2.aux.xml')) # Remove unused generated auxiliary file
  end

  context 'with a raster (geotiff)' do
    let(:druid) { 'druid:bb021mm7809' }
    let(:layer_name) { 'MCE_FI2G_2014' }
    let(:master_file) do
      Cocina::Models::File.new(
        type: 'https://cocina.sul.stanford.edu/models/file',
        externalIdentifier: "https://cocina.sul.stanford.edu/file/#{bare_druid}-#{bare_druid}_1/#{layer_name}.tif",
        label: "#{layer_name}.tif",
        filename: "#{layer_name}.tif",
        size: 100,
        version: 2,
        hasMimeType: 'image/tiff; application=geotiff',
        administrative: {
          publish: true,
          sdrPreserve: true,
          shelve: true
        }
      )
    end
    let(:cog_file_path) { workspace_path / "#{layer_name}_cog.tif" }

    after do
      FileUtils.rm_f(cog_file_path)
      FileUtils.rm_f(jp2_file_path)
    end

    # The generated COG's first band, as reported by gdalinfo.
    def cog_band
      result = GisRobotSuite.run_system_command("gdalinfo -json #{Shellwords.escape(cog_file_path.to_s)}", logger: logger)
      JSON.parse(result[:stdout_str])['bands'].first
    end

    def cog_data_type
      cog_band['type']
    end

    it 'creates a COG' do
      expect(cog_file_path).to exist
    end

    # No unit info in the fixture
    it 'does not declare a band unit' do
      expect(cog_band['unit']).to be_blank
    end

    it 'creates a JP2 thumbnail' do
      expect(jp2_file_path).to exist
    end

    it 'updates structural metadata' do
      expect(object_client).to have_received(:update) do |params:|
        new_contains = params.structural.contains.first.structural.contains
        expect(new_contains.count).to eq 3
        expect(new_contains.map(&:use)).to eq [nil, 'derivative', 'thumbnail']
        jp2_file = new_contains.find { |f| f.use == 'thumbnail' }
        expect(jp2_file.hasMimeType).to eq 'image/jp2'
        # Marked so a later run can tell this thumbnail apart from one the depositor supplied
        expect(jp2_file.sdrGeneratedText).to be true
        expect(jp2_file.presentation.height).to eq 7435
        expect(jp2_file.presentation.width).to eq 10503
      end
    end

    context 'with a continuous raster (Float64)' do
      let(:druid) { 'druid:sm159qy6116' }
      let(:layer_name) { 'PAR_CLIM_M' }

      it 'creates a COG that keeps the source data type' do
        expect(cog_file_path).to exist
        expect(cog_data_type).to eq 'Float64'
      end

      it 'creates a JP2 thumbnail' do
        expect(jp2_file_path).to exist
      end
    end

    context 'with a raster whose ESRI metadata declares a vertical coordinate system' do
      let(:druid) { 'druid:sf815vr1246' }
      let(:layer_name) { 'MONT_DEM' }

      it 'creates a COG that records the unit in the band' do
        expect(cog_file_path).to exist
        expect(cog_band['unit']).to eq 'm'
      end

      # Whole collections of rasters were accessioned with no ArcGIS metadata at all, and
      # locate_esri_metadata raises for those rather than returning nil.
      context 'when the sidecar is missing' do
        let(:esri_metadata_present) { false }

        it 'still creates a COG, just without a unit' do
          expect(cog_file_path).to exist
          expect(cog_band['unit']).to be_blank
        end
      end
    end

    context 'with a signed raster (Int8)' do
      let(:druid) { 'druid:bk526xr2877' }
      let(:layer_name) { 'SeafloorCharacter_OffshoreSantaBarbara' }

      it 'creates a COG that keeps the source data type' do
        expect(cog_file_path).to exist
        expect(cog_data_type).to eq 'Int8'
      end

      it 'creates a JP2 thumbnail' do
        expect(jp2_file_path).to exist
      end
    end

    context 'when the COG already exists in cocina' do
      let(:files) { [master_file, derivative_file] }
      let(:derivative_file) do
        Cocina::Models::File.new(
          type: 'https://cocina.sul.stanford.edu/models/file',
          externalIdentifier: "https://cocina.sul.stanford.edu/file/#{bare_druid}-#{bare_druid}_1/#{layer_name}_cog.tif",
          label: "#{layer_name}_cog.tif",
          filename: "#{layer_name}_cog.tif",
          size: 50,
          version: 2,
          hasMimeType: 'image/tiff; application=geotiff; profile=cloud-optimized',
          use: 'derivative',
          sdrGeneratedText: sdr_generated_text,
          administrative: {
            publish: true,
            sdrPreserve: false,
            shelve: true
          }
        )
      end

      context 'when the existing COG was generated by SDR' do
        let(:sdr_generated_text) { true }

        it 'replaces the derivative and adds a thumbnail' do
          expect(object_client).to have_received(:update) do |params:|
            new_contains = params.structural.contains.first.structural.contains
            expect(new_contains.count).to eq 3
            expect(new_contains.map(&:use)).to eq [nil, 'derivative', 'thumbnail']
            # Ensure the old derivative was removed and a new one added (new externalIdentifier)
            expect(new_contains.find { |f| f.hasMimeType.include?('profile=cloud-optimized') }.externalIdentifier).not_to eq derivative_file.externalIdentifier
          end
        end
      end

      context 'when the existing COG was not generated by SDR' do
        let(:sdr_generated_text) { false }

        it 'retains the original derivative and adds a thumbnail' do
          expect(object_client).to have_received(:update) do |params:|
            new_contains = params.structural.contains.first.structural.contains
            expect(new_contains.count).to eq 3
            expect(new_contains.map(&:use)).to eq [nil, 'derivative', 'thumbnail']
            # Ensure the old derivative was retained (same externalIdentifier)
            expect(new_contains.find { |f| f.hasMimeType.include?('profile=cloud-optimized') }.externalIdentifier).to eq derivative_file.externalIdentifier
          end
        end
      end
    end

    context 'when the JP2 thumbnail already exists in cocina' do
      let(:files) { [master_file, thumbnail_file] }
      let(:thumbnail_file) do
        Cocina::Models::File.new(
          type: 'https://cocina.sul.stanford.edu/models/file',
          externalIdentifier: "https://cocina.sul.stanford.edu/file/#{bare_druid}-#{bare_druid}_1/#{layer_name}.jp2",
          label: "#{layer_name}.jp2",
          filename: "#{layer_name}.jp2",
          size: 50,
          version: 2,
          hasMimeType: 'image/jp2',
          use: 'thumbnail',
          sdrGeneratedText: sdr_generated_text,
          administrative: {
            publish: true,
            sdrPreserve: false,
            shelve: true
          }
        )
      end

      context 'when the existing thumbnail was generated by SDR' do
        let(:sdr_generated_text) { true }

        it 'regenerates the JP2' do
          expect(jp2_file_path).to exist
        end

        it 'replaces the thumbnail' do
          expect(object_client).to have_received(:update) do |params:|
            new_contains = params.structural.contains.first.structural.contains
            expect(new_contains.count).to eq 3
            expect(new_contains.map(&:use)).to eq [nil, 'derivative', 'thumbnail']
            jp2_file = new_contains.find { |f| f.use == 'thumbnail' }
            # Ensure the stale thumbnail was removed and a new one added (new externalIdentifier)
            expect(jp2_file.externalIdentifier).not_to eq thumbnail_file.externalIdentifier
            expect(jp2_file.sdrGeneratedText).to be true
            expect(jp2_file.presentation.height).to eq 7435
            expect(jp2_file.presentation.width).to eq 10503
          end
        end
      end

      context 'when the existing thumbnail was not generated by SDR' do
        let(:sdr_generated_text) { false }

        it 'retains the original thumbnail and adds a COG' do
          expect(object_client).to have_received(:update) do |params:|
            new_contains = params.structural.contains.first.structural.contains
            expect(new_contains.count).to eq 3
            expect(new_contains.map(&:use)).to eq [nil, 'thumbnail', 'derivative']
            # Ensure the depositor's thumbnail was retained (same externalIdentifier)
            expect(new_contains.find { |f| f.use == 'thumbnail' }.externalIdentifier).to eq thumbnail_file.externalIdentifier
          end
        end
      end
    end

    # Re-accessioning through pre-assembly stages the previous run's COG back into the object, and
    # nothing left on it distinguishes a COG from the GeoTIFF it was derived from.
    context 'when a previous run has left its COG in the object as an ordinary GeoTIFF' do
      # Point the robot at a scratch copy of the content, since this rewrites what is in it
      let(:workspace_path) { staged_content_dir }
      let(:staged_content_dir) do
        Pathname(Dir.mktmpdir).join('content').tap do |dir|
          dir.mkpath
          FileUtils.cp(Dir.glob("spec/fixtures/workspace/bb/021/mm/7809/#{bare_druid}/content/#{layer_name}.*"), dir)
        end
      end
      let(:files) { [master_file, restaged_cog_file] }
      let(:restaged_cog_file) do
        Cocina::Models::File.new(
          type: 'https://cocina.sul.stanford.edu/models/file',
          externalIdentifier: "https://cocina.sul.stanford.edu/file/#{bare_druid}-#{bare_druid}_1/#{layer_name}_cog.tif",
          label: "#{layer_name}_cog.tif",
          filename: "#{layer_name}_cog.tif",
          size: restaged_cog_size,
          version: 2,
          hasMimeType: 'image/tiff; application=geotiff',
          sdrGeneratedText: false,
          administrative: { publish: true, sdrPreserve: true, shelve: true }
        )
      end
      # Staging the file has to happen before the robot runs, so hang it off a let the cocina object
      # pulls on rather than a before hook, which would fire after the outermost one has performed
      let(:restaged_cog_size) do
        FileUtils.cp(workspace_path / "#{layer_name}.tif", cog_file_path)
        File.size(cog_file_path)
      end

      after { FileUtils.remove_entry(staged_content_dir.parent) }

      it 'does not derive from it again' do
        expect(workspace_path / "#{layer_name}_cog_cog.tif").not_to exist
      end

      it 'takes it over as the COG derivative instead of recording a second one' do
        expect(object_client).to have_received(:update) do |params:|
          recorded = params.structural.contains.first.structural.contains
          expect(recorded.map(&:filename)).to contain_exactly("#{layer_name}.tif", "#{layer_name}_cog.tif", "#{layer_name}.jp2")
          cog = recorded.find { |file| file.filename == "#{layer_name}_cog.tif" }
          expect(cog).to have_attributes(use: 'derivative', hasMimeType: described_class::COG_MIME_TYPE,
                                         size: File.size(cog_file_path))
        end
      end
    end
  end

  context 'with vectors' do
    let(:fgb_file_path) { workspace_path / "#{layer_name}.fgb" }
    let(:pmtiles_file_path) { workspace_path / "#{layer_name}.pmtiles" }

    after do
      FileUtils.rm_f(fgb_file_path)
      FileUtils.rm_f(pmtiles_file_path)
    end

    context 'with a shapefile' do
      let(:druid) { 'druid:cc044gt0726' }
      let(:layer_name) { 'sanluisobispo1996' }
      let(:master_file) do
        Cocina::Models::File.new(
          type: 'https://cocina.sul.stanford.edu/models/file',
          externalIdentifier: "https://cocina.sul.stanford.edu/fileSet/#{bare_druid}-#{bare_druid}_1/#{layer_name}.shp",
          label: "#{layer_name}.shp",
          filename: "#{layer_name}.shp",
          size: 100,
          version: 2,
          hasMimeType: 'application/vnd.shp',
          administrative: {
            publish: true,
            sdrPreserve: true,
            shelve: true
          }
        )
      end

      it 'creates a FlatGeoBuf' do
        expect(fgb_file_path).to exist
      end

      it 'creates a PMTiles archive' do
        expect(pmtiles_file_path).to exist
      end

      it 'creates a JP2 thumbnail' do
        expect(jp2_file_path).to exist
      end

      it 'updates structural metadata' do
        expect(object_client).to have_received(:update) do |params:|
          new_contains = params.structural.contains.first.structural.contains
          expect(new_contains.count).to eq 4
          expect(new_contains.map(&:use)).to eq [nil, 'derivative', 'derivative', 'thumbnail']
          expect(new_contains.map(&:hasMimeType)).to contain_exactly('application/vnd.shp', 'application/vnd.fgb', 'application/vnd.pmtiles', 'image/jp2')
          jp2_file = new_contains.find { |f| f.use == 'thumbnail' }
          expect(jp2_file.sdrGeneratedText).to be true
          expect(jp2_file.presentation.height).to eq 512
          expect(jp2_file.presentation.width).to eq 512
        end
      end

      context 'with mixed single/multi geometry type' do
        let(:druid) { 'druid:cz128vq0535' }
        let(:layer_name) { 'Ug_Rural_Poverty2005' }

        it 'successfully creates the FlatGeoBuf and PMTile by promoting to multi' do
          perform
          expect(fgb_file_path).to exist
          expect(pmtiles_file_path).to exist
        end
      end

      context 'with features that have invalid geometry' do
        let(:druid) { 'druid:cq376yf4339' }
        let(:layer_name) { 'BIO_CA_Mammal_Pinnipeds_Haulouts_MLPAcompilation' }

        it 'successfully creates the FlatGeoBuf and PMTiles archive by dropping invalid geometries' do
          perform
          expect(fgb_file_path).to exist
          expect(pmtiles_file_path).to exist
        end
      end

      context 'with a single-feature point layer (tippecanoe -zg cannot guess a maxzoom)' do
        let(:druid) { 'druid:bc041ny0861' }
        let(:layer_name) { 'Pusan_CBD' }

        it 'successfully creates the FlatGeoBuf and PMTiles archive by falling back to a fixed maxzoom' do
          perform
          expect(fgb_file_path).to exist
          expect(pmtiles_file_path).to exist
        end
      end

      context 'when the derivatives already exist in cocina' do
        let(:files) { [master_file, derivative_fgb_file, derivative_pmtiles_file] }
        let(:derivative_fgb_file) do
          Cocina::Models::File.new(
            type: 'https://cocina.sul.stanford.edu/models/file',
            externalIdentifier: "https://cocina.sul.stanford.edu/file/#{bare_druid}-#{bare_druid}_1/#{layer_name}.fgb",
            label: "#{layer_name}.fgb",
            filename: "#{layer_name}.fgb",
            size: 50,
            version: 2,
            hasMimeType: 'application/vnd.fgb',
            use: 'derivative',
            sdrGeneratedText: sdr_generated_text,
            administrative: { publish: true, sdrPreserve: false, shelve: true }
          )
        end

        let(:derivative_pmtiles_file) do
          Cocina::Models::File.new(
            type: 'https://cocina.sul.stanford.edu/models/file',
            externalIdentifier: "https://cocina.sul.stanford.edu/file/#{bare_druid}-#{bare_druid}_1/#{layer_name}.pmtiles",
            label: "#{layer_name}.pmtiles",
            filename: "#{layer_name}.pmtiles",
            size: 50,
            version: 2,
            hasMimeType: 'application/vnd.pmtiles',
            use: 'derivative',
            sdrGeneratedText: sdr_generated_text,
            administrative: { publish: true, sdrPreserve: false, shelve: true }
          )
        end

        context 'when the derivatives were generated by SDR' do
          let(:sdr_generated_text) { true }

          it 'replaces all derivatives' do
            expect(object_client).to have_received(:update) do |params:|
              new_contains = params.structural.contains.first.structural.contains
              expect(new_contains.count).to eq 4
              # Ensure the old derivatives were removed and new ones added
              expect(new_contains.count { |f| f.use == 'derivative' }).to eq 2
              expect(new_contains.count { |f| f.use == 'thumbnail' }).to eq 1
              derivatives = new_contains.select { |f| f.use == 'derivative' }
              expect(derivatives.map(&:externalIdentifier)).not_to include(derivative_fgb_file.externalIdentifier)
              expect(derivatives.map(&:externalIdentifier)).not_to include(derivative_pmtiles_file.externalIdentifier)
              expect(derivatives.map(&:hasMimeType)).to contain_exactly('application/vnd.fgb', 'application/vnd.pmtiles')
              expect(new_contains.find { |f| f.use == 'thumbnail' }.hasMimeType).to eq 'image/jp2'
            end
          end
        end

        context 'when the derivatives were not generated by SDR' do
          let(:sdr_generated_text) { false }

          it 'retains all derivatives' do
            expect(object_client).to have_received(:update) do |params:|
              new_contains = params.structural.contains.first.structural.contains
              expect(new_contains.count).to eq 4
              # Ensure the old derivatives were preserved
              expect(new_contains.count { |f| f.use == 'derivative' }).to eq 2
              expect(new_contains.count { |f| f.use == 'thumbnail' }).to eq 1
              derivatives = new_contains.select { |f| f.use == 'derivative' }
              expect(derivatives.map(&:externalIdentifier)).to include(derivative_fgb_file.externalIdentifier)
              expect(derivatives.map(&:externalIdentifier)).to include(derivative_pmtiles_file.externalIdentifier)
              expect(derivatives.map(&:hasMimeType)).to contain_exactly('application/vnd.fgb', 'application/vnd.pmtiles')
              expect(new_contains.find { |f| f.use == 'thumbnail' }.hasMimeType).to eq 'image/jp2'
            end
          end
        end
      end
    end

    context 'with a shapefile that has no .prj' do
      let(:druid) { 'druid:cf920rt3856' }
      let(:layer_name) { 'Pusan_CBD' }
      let(:cocina_object) do
        build(:dro, id: druid).new(structural: structural, access: { view: 'world' }, description: description)
      end
      let(:description) do
        {
          title: [{ value: 'Pusan CBD' }],
          form: [{ value: 'EPSG::32652', type: 'map projection' }],
          purl: "https://purl.stanford.edu/#{bare_druid}"
        }
      end
      let(:master_file) do
        Cocina::Models::File.new(
          type: 'https://cocina.sul.stanford.edu/models/file',
          externalIdentifier: "https://cocina.sul.stanford.edu/file/#{bare_druid}-#{bare_druid}_1/#{layer_name}.shp",
          label: "#{layer_name}.shp",
          filename: "#{layer_name}.shp",
          size: 100,
          version: 2,
          hasMimeType: 'application/vnd.shp',
          administrative: {
            publish: true,
            sdrPreserve: true,
            shelve: true
          }
        )
      end

      it 'creates a FlatGeoBuf using the projection cocina recorded' do
        expect(fgb_file_path).to exist
      end

      it 'creates a PMTiles archive' do
        expect(pmtiles_file_path).to exist
      end
    end

    context 'with geojson' do
      let(:druid) { 'druid:yt111kw1413' }
      let(:layer_name) { 'samTrans_bus_routes_20151021_shapes_20260406' }
      let(:master_file) do
        Cocina::Models::File.new(
          type: 'https://cocina.sul.stanford.edu/models/file',
          externalIdentifier: "https://cocina.sul.stanford.edu/file/#{bare_druid}-#{bare_druid}_1/#{layer_name}.geojson",
          label: "#{layer_name}.geojson",
          filename: "#{layer_name}.geojson",
          size: 100,
          version: 2,
          hasMimeType: 'application/geo+json',
          administrative: {
            publish: true,
            sdrPreserve: true,
            shelve: true
          }
        )
      end

      it 'creates a FlatGeoBuf' do
        expect(fgb_file_path).to exist
      end

      it 'creates a PMTiles archive' do
        expect(pmtiles_file_path).to exist
      end

      it 'creates a JP2 thumbnail' do
        expect(jp2_file_path).to exist
      end

      it 'updates structural metadata' do
        expect(object_client).to have_received(:update) do |params:|
          new_contains = params.structural.contains.first.structural.contains
          expect(new_contains.count).to eq 4
          expect(new_contains.map(&:use)).to eq [nil, 'derivative', 'derivative', 'thumbnail']
          expect(new_contains.map(&:hasMimeType)).to contain_exactly('application/geo+json', 'application/vnd.fgb', 'application/vnd.pmtiles', 'image/jp2')
          jp2_file = new_contains.find { |f| f.use == 'thumbnail' }
          expect(jp2_file.presentation.height).to eq 512
          expect(jp2_file.presentation.width).to eq 512
        end
      end
    end

    # Both of these arise from re-accessioning an already-derived object through pre-assembly, which
    # stages an earlier run's derivatives back into the object as ordinary content.
    context 'when a previous run has left its derivatives in the object' do
      let(:druid) { 'druid:cc044gt0726' }
      let(:layer_name) { 'sanluisobispo1996' }
      # Point the robot at a scratch copy of the content, since these examples rewrite what is in it
      let(:workspace_path) { staged_content_dir }
      let(:staged_content_dir) do
        Pathname(Dir.mktmpdir).join('content').tap do |dir|
          dir.mkpath
          FileUtils.cp(Dir.glob("#{fixture_content_dir}/#{layer_name}.*"), dir)
        end
      end
      let(:fixture_content_dir) { "spec/fixtures/workspace/cc/044/gt/0726/#{bare_druid}/content" }
      let(:master_file) do
        Cocina::Models::File.new(
          type: 'https://cocina.sul.stanford.edu/models/file',
          externalIdentifier: "https://cocina.sul.stanford.edu/file/#{bare_druid}-#{bare_druid}_1/#{layer_name}.shp",
          label: "#{layer_name}.shp",
          filename: "#{layer_name}.shp",
          size: 100,
          version: 2,
          hasMimeType: 'application/vnd.shp',
          administrative: { publish: true, sdrPreserve: true, shelve: true }
        )
      end

      # Pre-assembly records the staged file as plain content: no use, and a mimetype it did not
      # recognize. It is a valid FlatGeoBuf, so ogr2ogr will happily rewrite it in place.
      let(:files) { [master_file, restaged_fgb_file] }
      let(:restaged_fgb_file) do
        Cocina::Models::File.new(
          type: 'https://cocina.sul.stanford.edu/models/file',
          externalIdentifier: "https://cocina.sul.stanford.edu/file/#{bare_druid}-#{bare_druid}_1/#{layer_name}.fgb",
          label: "#{layer_name}.fgb",
          filename: "#{layer_name}.fgb",
          size: restaged_fgb_size,
          version: 2,
          hasMimeType: 'application/octet-stream',
          sdrGeneratedText: false,
          administrative: { publish: true, sdrPreserve: true, shelve: true }
        )
      end
      let(:restaged_fgb_size) do
        GisRobotSuite::VectorDerivativeGenerator.generate(
          input_path: staged_content_dir / "#{layer_name}.shp", fgb_path: fgb_file_path,
          pmtiles_path: staged_content_dir / "#{layer_name}.pmtiles", logger: logger
        )
        # Truncating stands in for the earlier run having produced different bytes than this one will
        File.truncate(fgb_file_path, File.size(fgb_file_path) - 1)
        File.size(fgb_file_path)
      end

      after { FileUtils.remove_entry(staged_content_dir.parent) }

      it 'records the derivative it wrote rather than leaving the stale record behind' do
        expect(object_client).to have_received(:update) do |params:|
          recorded = params.structural.contains.first.structural.contains
                           .select { |file| file.filename == "#{layer_name}.fgb" }
          expect(recorded.size).to eq 1
          expect(recorded.first).to have_attributes(use: 'derivative', hasMimeType: 'application/vnd.fgb',
                                                    size: File.size(fgb_file_path))
          expect(recorded.first.size).not_to eq restaged_fgb_size
        end
      end

      it 'stops preserving the file it has taken over as a derivative' do
        expect(object_client).to have_received(:update) do |params:|
          recorded = params.structural.contains.first.structural.contains
                           .find { |file| file.filename == "#{layer_name}.fgb" }
          expect(recorded.administrative.sdrPreserve).to be false
        end
      end

      context 'when the file it left behind is not a readable FlatGeoBuf' do
        let(:restaged_fgb_size) do
          File.binwrite(fgb_file_path, 'not a FlatGeoBuf')
          File.size(fgb_file_path)
        end

        it 'still generates the derivative' do
          expect(fgb_file_path).to exist
          expect(File.size(fgb_file_path)).to be > restaged_fgb_size
        end
      end
    end

    context 'when the file set holds more than one vector master' do
      let(:druid) { 'druid:cc044gt0726' }
      let(:layer_name) { 'sanluisobispo1996' }
      let(:workspace_path) { staged_content_dir }
      let(:staged_content_dir) do
        Pathname(Dir.mktmpdir).join('content').tap do |dir|
          dir.mkpath
          FileUtils.cp(Dir.glob("spec/fixtures/workspace/cc/044/gt/0726/#{bare_druid}/content/#{layer_name}.*"), dir)
          FileUtils.cp('spec/fixtures/workspace/yt/111/kw/1413/yt111kw1413/content/' \
                       'samTrans_bus_routes_20151021_shapes_20260406.geojson', dir / 'index_map.geojson')
        end
      end
      let(:files) { [shapefile_master, geojson_master] }
      let(:shapefile_master) do
        Cocina::Models::File.new(
          type: 'https://cocina.sul.stanford.edu/models/file',
          externalIdentifier: "https://cocina.sul.stanford.edu/file/#{bare_druid}-#{bare_druid}_1/#{layer_name}.shp",
          label: "#{layer_name}.shp",
          filename: "#{layer_name}.shp",
          size: 100,
          version: 2,
          hasMimeType: 'application/vnd.shp',
          administrative: { publish: true, sdrPreserve: true, shelve: true }
        )
      end
      let(:geojson_master) do
        Cocina::Models::File.new(
          type: 'https://cocina.sul.stanford.edu/models/file',
          externalIdentifier: "https://cocina.sul.stanford.edu/file/#{bare_druid}-#{bare_druid}_1/index_map.geojson",
          label: 'index_map.geojson',
          filename: 'index_map.geojson',
          size: 100,
          version: 2,
          hasMimeType: 'application/geo+json',
          administrative: { publish: true, sdrPreserve: true, shelve: true }
        )
      end

      after { FileUtils.remove_entry(staged_content_dir.parent) }

      it 'records the derivatives of every master, not just the last one' do
        expect(object_client).to have_received(:update) do |params:|
          derivatives = params.structural.contains.first.structural.contains
                              .select { |file| file.use == 'derivative' }
          expect(derivatives.map(&:filename)).to contain_exactly(
            "#{layer_name}.fgb", "#{layer_name}.pmtiles", 'index_map.fgb', 'index_map.pmtiles'
          )
        end
      end

      it 'records a size for each derivative matching the file it wrote' do
        expect(object_client).to have_received(:update) do |params:|
          params.structural.contains.first.structural.contains
                .select { |file| file.use == 'derivative' }
                .each { |file| expect(file.size).to eq File.size(staged_content_dir / file.filename) }
        end
      end

      it 'still records a single thumbnail for the file set' do
        expect(object_client).to have_received(:update) do |params:|
          thumbnails = params.structural.contains.first.structural.contains
                             .select { |file| file.use == 'thumbnail' }
          expect(thumbnails.map(&:filename)).to eq ["#{layer_name}.jp2"]
        end
      end

      # Generating a thumbnail per master would leave every JP2 but the last one on disk with no
      # record of it, since each master's thumbnail discards the record the previous one wrote
      it 'writes only the thumbnail it records' do
        expect(Dir.glob("#{staged_content_dir}/*.jp2").map { |path| File.basename(path) })
          .to eq ["#{layer_name}.jp2"]
      end
    end
  end
end
