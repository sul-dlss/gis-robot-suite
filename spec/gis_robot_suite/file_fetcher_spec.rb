# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::FileFetcher do
  let(:file_fetcher) { described_class.new(druid:, logger:) }
  let(:logger) { instance_double(Logger, warn: nil, info: nil, error: nil) }
  let(:druid) { 'druid:bb222cc3333' }
  let(:bare_druid) { 'bb222cc3333' }
  let(:base_dir) { "tmp/#{bare_druid}" }
  let(:found_response) { { status: 200, body: "Content for: #{filename}", headers: {} } }
  let(:not_found_response) { { status: 404, body: 'Not found' } }

  before do
    FileUtils.mkdir_p(base_dir)
    allow(file_fetcher).to receive(:sleep) # effectively make the sleep a no-op so that the test doesn't take so long due to retries and backoff
    allow(Honeybadger).to receive(:notify)

    stub_request(:get, "#{Settings.preservation_catalog.url}/v1/objects/#{druid}/file?category=content&filepath=#{filename}&version")
      .with(
        headers: { 'Accept' => '*/*',
                   'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                   'Authorization' => "Bearer #{Settings.preservation_catalog.token}" }
      ).to_return(response)
  end

  after do
    FileUtils.rm_rf(base_dir)
  end

  describe '#write_file_with_retries' do
    context 'when writing to disk' do
      let(:filename) { 'image111.tif' }
      let(:file_path) { File.join(base_dir, filename) }
      let(:location) { Pathname.new(file_path) }
      let(:response) { found_response }

      context 'when preservation is done' do
        it 'writes the file' do
          file_fetcher.write_file_with_retries(filename:, location:)
          expect(logger).to have_received(:info).once
          expect(File.read(file_path)).to eq("Content for: #{filename}")
        end
      end

      context 'when preservation is still processing' do
        let(:response) { [not_found_response, not_found_response, found_response] }

        it 'eventually writes the file, warns twice, but no HB alert' do
          file_fetcher.write_file_with_retries(filename:, location:)
          expect(logger).to have_received(:warn).twice
          expect(Honeybadger).not_to have_received(:notify)
          expect(File.read(file_path)).to eq("Content for: #{filename}")
        end

        context 'when retries are exhausted before the files show up on the preservation NFS mount' do
          let(:response) { [not_found_response, not_found_response, not_found_response] }

          it 'returns false, sends to HB, and logs an error' do
            written = file_fetcher.write_file_with_retries(filename:, location:)
            expect(written).to be(false)

            context = { druid:, filename:, max_tries: 3, path: file_path }
            expect(logger).to have_received(:error).with("Exceeded max_tries attempting to fetch file: #{context}")
            expect(Honeybadger).to have_received(:notify).with('Exceeded max_tries attempting to fetch file', context:)
            expect(file_fetcher).to have_received(:sleep).with((Settings.sleep_coefficient * 2)**3) # should have hit max backoff time of 2^3 seconds
          end

          it 'leaves nothing in the destination directory' do
            file_fetcher.write_file_with_retries(filename:, location:)
            expect(location).not_to exist
            expect(Dir.children(base_dir)).to be_empty
          end
        end
      end

      context 'when a file is already at the location' do
        before { File.write(file_path, 'stale content') }

        it 'replaces it with the fetched file' do
          file_fetcher.write_file_with_retries(filename:, location:)
          expect(File.read(file_path)).to eq("Content for: #{filename}")
          expect(Dir.children(base_dir)).to eq([filename])
        end

        context 'when retries are exhausted' do
          let(:response) { not_found_response }

          it 'returns false and leaves the existing file alone' do
            expect(file_fetcher.write_file_with_retries(filename:, location:)).to be(false)
            expect(File.read(file_path)).to eq('stale content')
            expect(Dir.children(base_dir)).to eq([filename])
          end
        end
      end

      context 'when the fetch fails partway through' do
        let(:objects) { instance_double(Preservation::Client::Objects) }

        before do
          allow(file_fetcher).to receive(:preservation_client).and_return(instance_double(Preservation::Client, objects:))
          allow(objects).to receive(:content) do |on_data:, **|
            on_data.call('partial content', 15)
            raise Faraday::ConnectionFailed, 'connection reset'
          end
        end

        it 'raises and leaves nothing in the destination directory' do
          expect { file_fetcher.write_file_with_retries(filename:, location:) }.to raise_error(Faraday::ConnectionFailed)
          expect(location).not_to exist
          expect(Dir.children(base_dir)).to be_empty
        end
      end
    end

    context 'when passing an invalid location' do
      let(:filename) { 'image111.tif' }
      let(:location) { {} } # not an Aws::S3::Object or an instance of Pathname or a string
      let(:response) { found_response }

      it 'raises an error' do
        expect { file_fetcher.write_file_with_retries(filename:, location:) }.to raise_error(RuntimeError, 'Unknown location type: Hash')
      end
    end
  end
end
