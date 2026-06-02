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

  describe '#add_file' do
    let(:filename) { File.join(fixture_dir, 'stage/bb045mm1234/content/somefile.txt') }
    let(:mimetype) { 'text/plain' }
    let(:use) { 'derivative' }

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
        updated_object = updater.add_file(filename: filename, mimetype: mimetype, use: use, file_set: file_sets.first)
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
        updated_object = updater.add_file(filename: filename, mimetype: mimetype, use: use, file_set: file_sets.first)
        expect(updated_object.structural.contains.size).to eq 2
        expect(updated_object.structural.contains.first.structural.contains.size).to eq 1
        expect(updated_object.structural.contains.last.structural.contains.size).to eq 0
      end

      it 'adds the file to a specific file set if provided' do
        updated_object = updater.add_file(filename: filename, mimetype: mimetype, use: use, file_set: file_sets.last)
        expect(updated_object.structural.contains.size).to eq 2
        expect(updated_object.structural.contains.first.structural.contains.size).to eq 0
        expect(updated_object.structural.contains.last.structural.contains.size).to eq 1
      end
    end
  end

  describe '#remove_files' do
    let(:file_sets) do
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
                label: 'master.tif',
                filename: 'master.tif',
                version: 1,
                hasMimeType: 'image/tiff',
                use: 'master',
                administrative: { publish: true, sdrPreserve: true, shelve: true },
                access: { view: 'world', download: 'world' },
                hasMessageDigests: []
              },
              {
                type: 'https://cocina.sul.stanford.edu/models/file',
                externalIdentifier: 'https://cocina.sul.stanford.edu/file/2',
                label: 'derivative.tif',
                filename: 'derivative.tif',
                version: 1,
                hasMimeType: 'image/tiff',
                use: 'derivative',
                administrative: { publish: true, sdrPreserve: false, shelve: true },
                access: { view: 'world', download: 'world' },
                hasMessageDigests: []
              }
            ]
          }
        )
      ]
    end

    it 'removes files by use' do
      updater.remove_files(use: 'derivative', file_set: file_sets.first)
      expect(updater.cocina_object.structural.contains.first.structural.contains.size).to eq 1
      expect(updater.cocina_object.structural.contains.first.structural.contains.first.use).to eq 'master'
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
end
