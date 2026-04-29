# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::DataFileBuilder do
  subject(:builder) { described_class.new(content_dir:, file_access:, version:) }

  let(:content_dir) { 'path/to/content' }
  let(:file_access) { {} }
  let(:version) { 1 }

  describe '#build' do
    context 'when a pmtiles file is provided' do
      before do
        allow(GisRobotSuite::DataFileFinder).to receive(:find).and_return([pmtiles_path])
        allow(SecureRandom).to receive(:uuid).and_return(id)
      end

      let(:id) { '4e1c91a3-8624-4b71-a641-4b78ef2b61c5' }

      let(:pmtiles_path) { 'spec/fixtures/stage/foo.pmtiles' }
      let(:expected_params) do
        {
          type: 'https://cocina.sul.stanford.edu/models/file',
          externalIdentifier: "https://cocina.sul.stanford.edu/file/#{id}",
          label: 'foo.pmtiles',
          filename: 'foo.pmtiles',
          size: 6,
          version: 1,
          hasMimeType: 'application/vnd.pmtiles',
          use: 'master',
          hasMessageDigests: [
            {
              type: 'sha1',
              digest: '8843d7f92416211de9ebb963ff4ce28125932878'
            },
            {
              type: 'md5',
              digest: '3858f62230ac3c915f300c664312c63f'
            }
          ],
          access: {},
          administrative: {
            publish: true,
            sdrPreserve: true,
            shelve: true
          }
        }
      end

      around do |example|
        File.write(pmtiles_path, 'foobar')
        example.run
        FileUtils.rm_f(pmtiles_path)
      end

      it 'returns the pmtiles file path' do
        expect(builder.build).to eq [expected_params]
      end
    end
  end
end
