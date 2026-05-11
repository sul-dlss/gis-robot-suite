# frozen_string_literal: true

module GisRobotSuite
  # Fetch files from preservation to make them available for derivative generation
  # Copied from https://github.com/sul-dlss/common-accessioning/blob/e1e029e6cbeba89d19189d57bfefd96a3dbc8e62/lib/dor/text_extraction/file_fetcher.rb#L5
  class FileFetcher
    attr_reader :druid, :logger

    def initialize(druid:, logger: nil)
      @druid = druid
      @logger = logger || Logger.new($stdout)
    end

    # Fetch an item's file from Preservation and write it to disk. Since
    # we've observed inconsistency in QA and Stage with the NFS volumes
    # where files are written, we need to recheck.
    # This method will retry fetching the file up to `max_tries` times.
    # @param [String] filename the filename to fetch
    # @param [Object] location to write the file (could be a Pathname object, a string representing a local path)
    # @param [Integer] max_tries the number of times to retry fetching the file
    # @return [Boolean] true if the file was fetched and written, false otherwise
    def write_file_with_retries(filename:, location:, max_tries: 3)
      tries = 0
      written = false
      begin
        written = if location.is_a?(String) || location.is_a?(Pathname)
                    fetch_and_write_file_to_disk(filename:, path: Pathname.new(location))
                  else
                    raise "Unknown location type: #{location.class}"
                  end
      rescue Preservation::Client::NotFoundError, Faraday::ResourceNotFound
        tries += 1
        logger.warn("received NotFoundError from Preservation try ##{tries}")

        sleep((Settings.sleep_coefficient * 2)**tries)

        retry unless tries > max_tries

        context = { druid:, filename:, max_tries: }.tap do |ctx|
          ctx[:path] = location.to_s if location.is_a?(Pathname) || location.is_a?(String)
        end

        logger.error("Exceeded max_tries attempting to fetch file: #{context}")
        Honeybadger.notify('Exceeded max_tries attempting to fetch file', context:)
      end

      written
    end

    private

    # fetch a file from perservation and write to disk
    def fetch_and_write_file_to_disk(filename:, path:)
      path.open('wb') do |file_writer|
        logger.info("fetching #{filename} for #{druid} and saving to #{path}")
        preservation_client.objects.content(
          druid:,
          filepath: filename,
          on_data: proc { |data, _count| file_writer.write(data) }
        )
      end

      true
    end

    def preservation_client
      @preservation_client ||= Preservation::Client.configure(url: Settings.preservation_catalog.url, token: Settings.preservation_catalog.token)
    end
  end
end
