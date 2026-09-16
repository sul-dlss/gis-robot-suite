# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::StructuralUpdator do
  let(:druid) { 'druid:bb045mm1234' }
  let(:cocina_object) do
    build(:dro, id: druid).new(
      structural: {
        contains: file_sets
      },
      access: { view: 'world', download: 'world' },
      version: 1
    )
  end
  let(:file_sets) { [] }
  let(:updater) { described_class.new(cocina_object) }

  # A file set holding a depositor original alongside an SDR-generated derivative
  let(:derivative_file) do
    {
      type: 'https://cocina.sul.stanford.edu/models/file',
      externalIdentifier: 'https://cocina.sul.stanford.edu/file/2',
      label: 'derivative.tif',
      filename: 'derivative.tif',
      version: 1,
      hasMimeType: 'image/tiff',
      use: 'derivative',
      sdrGeneratedText: true,
      administrative: { publish: true, sdrPreserve: false, shelve: true },
      access: { view: 'world', download: 'world' },
      hasMessageDigests: []
    }
  end

  let(:file_sets_with_derivative) do
    [
      Cocina::Models::FileSet.new(
        type: 'https://cocina.sul.stanford.edu/models/resources/object',
        externalIdentifier: 'https://cocina.sul.stanford.edu/fileset/1',
        label: 'Fileset 1',
        version: 1,
        structural: {
          contains: [
            {
              type: 'https://cocina.sul.stanford.edu/models/file',
              externalIdentifier: 'https://cocina.sul.stanford.edu/file/1',
              label: 'original.tif',
              filename: 'original.tif',
              version: 1,
              hasMimeType: 'image/tiff',
              administrative: { publish: true, sdrPreserve: true, shelve: true },
              access: { view: 'world', download: 'world' },
              hasMessageDigests: []
            },
            derivative_file
          ]
        }
      )
    ]
  end

  def new_file_set
    Cocina::Models::FileSet.new(
      type: 'https://cocina.sul.stanford.edu/models/resources/object',
      externalIdentifier: "https://cocina.sul.stanford.edu/fileset/#{SecureRandom.uuid}",
      label: '',
      version: cocina_object.version,
      structural: { contains: [] }
    )
  end

  describe '#add_file' do
    let(:filename) { File.join(fixture_dir, 'stage/bb045mm1234/content/somefile.txt') }
    let(:mimetype) { 'text/plain' }
    let(:use) { 'derivative' }

    context 'when there are no file sets' do
      let(:updated_object) do
        updater.add_file(filename: filename, use: use, file_set: new_file_set, mimetype: mimetype)
      end
      let(:created_file_sets) { updated_object.structural.contains }
      let(:files) { created_file_sets.first.structural.contains }

      it 'adds to the provided file set and creates structural contains' do
        expect(created_file_sets.size).to eq 1
        expect(files.size).to eq 1
        expect(files.first.filename).to eq File.basename(filename)
        expect(files.first.sdrGeneratedText).to be true
      end

      context 'when a thumbnail' do
        let(:use) { 'thumbnail' }

        it 'marks the file as SDR generated' do
          expect(files.first.sdrGeneratedText).to be true
        end
      end

      context 'when not a derivative' do
        let(:use) { 'main' }

        it 'adds to the provided file set and creates structural contains' do
          expect(created_file_sets.size).to eq 1
          expect(files.size).to eq 1
          expect(files.first.filename).to eq File.basename(filename)
          expect(files.first.sdrGeneratedText).to be false
        end
      end
    end

    context 'when there is one file set' do
      let(:file_sets) do
        [
          Cocina::Models::FileSet.new(
            type: 'https://cocina.sul.stanford.edu/models/resources/object',
            externalIdentifier: 'https://cocina.sul.stanford.edu/fileset/1234',
            label: 'Fileset 1',
            version: 1,
            structural: { contains: [] }
          )
        ]
      end

      it 'adds the file to the existing file set' do
        updated_object = updater.add_file(filename: filename, use: use, file_set: file_sets.first, mimetype: mimetype)
        expect(updated_object.structural.contains.size).to eq 1
        expect(updated_object.structural.contains.first.externalIdentifier).to eq 'https://cocina.sul.stanford.edu/fileset/1234'
        expect(updated_object.structural.contains.first.structural.contains.size).to eq 1
      end
    end

    context 'when there are multiple file sets' do
      let(:file_sets) do
        [
          Cocina::Models::FileSet.new(
            type: 'https://cocina.sul.stanford.edu/models/resources/object',
            externalIdentifier: 'https://cocina.sul.stanford.edu/fileset/1',
            label: 'Fileset 1',
            version: 1,
            structural: { contains: [] }
          ),
          Cocina::Models::FileSet.new(
            type: 'https://cocina.sul.stanford.edu/models/resources/object',
            externalIdentifier: 'https://cocina.sul.stanford.edu/fileset/2',
            label: 'Fileset 2',
            version: 1,
            structural: { contains: [] }
          )
        ]
      end

      it 'adds the file to the provided file set' do
        updated_object = updater.add_file(filename: filename, use: use, file_set: file_sets.first, mimetype: mimetype)
        expect(updated_object.structural.contains.size).to eq 2
        expect(updated_object.structural.contains.first.structural.contains.size).to eq 1
        expect(updated_object.structural.contains.last.structural.contains.size).to eq 0
      end

      it 'adds the file to a specific file set if provided' do
        updated_object = updater.add_file(filename: filename, use: use, file_set: file_sets.last, mimetype: mimetype)
        expect(updated_object.structural.contains.size).to eq 2
        expect(updated_object.structural.contains.first.structural.contains.size).to eq 0
        expect(updated_object.structural.contains.last.structural.contains.size).to eq 1
      end
    end
  end

  describe '#remove_files' do
    let(:file_sets) { file_sets_with_derivative }

    it 'removes files by use' do
      updater.remove_files(use: 'derivative', file_set: file_sets.first)
      expect(updater.cocina_object.structural.contains.first.structural.contains.size).to eq 1
      expect(updater.cocina_object.structural.contains.first.structural.contains.first.use).to be_nil
    end

    context 'when the file was not generated by SDR' do
      let(:derivative_file) do
        super().merge(sdrGeneratedText: false)
      end

      it 'leaves the depositor-supplied file alone' do
        updater.remove_files(use: 'derivative', file_set: file_sets.first)
        expect(updater.cocina_object.structural.contains.first.structural.contains.size).to eq 2
      end
    end

    it 'removes files by use and mimetype' do
      updater.remove_files(use: 'derivative', mimetype: 'image/tiff', file_set: file_sets.first)
      expect(updater.cocina_object.structural.contains.first.structural.contains.size).to eq 1

      # Reset the updater with the original object for the next test
      fresh_updater = described_class.new(cocina_object)
      fresh_updater.remove_files(use: 'derivative', mimetype: 'text/plain', file_set: file_sets.first)
      expect(fresh_updater.cocina_object.structural.contains.first.structural.contains.size).to eq 2
    end
  end

  describe '#find_file' do
    let(:file_sets) { file_sets_with_derivative }

    it 'returns the file with that filename' do
      expect(updater.find_file(filename: 'derivative.tif', file_set: file_sets.first).externalIdentifier)
        .to eq 'https://cocina.sul.stanford.edu/file/2'
    end

    it 'returns nil when the file set holds no such file' do
      expect(updater.find_file(filename: 'nonexistent.tif', file_set: file_sets.first)).to be_nil
    end
  end

  describe '#remove_file' do
    let(:file_sets) { file_sets_with_derivative }

    # Unlike #remove_files, this does not care whether SDR generated the file: the point is to drop
    # a record that no longer describes what is on disk.
    it 'removes the file with that filename regardless of use or sdrGeneratedText' do
      updater.remove_file(filename: 'original.tif', file_set: file_sets.first)
      remaining = updater.cocina_object.structural.contains.first.structural.contains
      expect(remaining.map(&:filename)).to eq ['derivative.tif']
    end

    it 'leaves the file set alone when it holds no such file' do
      updater.remove_file(filename: 'nonexistent.tif', file_set: file_sets.first)
      remaining = updater.cocina_object.structural.contains.first.structural.contains
      expect(remaining.map(&:filename)).to eq ['original.tif', 'derivative.tif']
    end
  end
end
