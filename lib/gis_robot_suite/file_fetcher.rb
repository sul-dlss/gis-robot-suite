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
    # The file is only moved into place once it has been fetched in full, so
    # a failed fetch leaves nothing at `location` (and leaves any file already
    # there untouched).
    # @param [String] filename the filename to fetch
    # @param [Object] location to write the file (could be a Pathname object, a string representing a local path)
    # @param [Integer] max_tries the number of times to retry fetching the file
    # @return [Boolean] true if the file was fetched and written, false otherwise
    def write_file_with_retries(filename:, location:, max_tries: 3) # rubocop:disable Naming/PredicateMethod
      tries = 0
      begin
        raise "Unknown location type: #{location.class}" unless location.is_a?(String) || location.is_a?(Pathname)

        fetch_and_write_file_to_disk(filename:, path: Pathname.new(location))
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
        return false
      end
      true
    end

    private

    # Fetch a file from preservation into a temporary file alongside `path`, then
    # rename it into place. Opening `path` itself before the fetch would leave an
    # empty (or partial) file there whenever the fetch fails, and later runs would
    # take that file as already fetched.
    def fetch_and_write_file_to_disk(filename:, path:)
      temp_path = temp_path_for(path)
      logger.info("fetching #{filename} for #{druid} and saving to #{path}")
      temp_path.open('wb') do |file_writer|
        preservation_client.objects.content(
          druid:,
          filepath: filename,
          on_data: proc { |data, _count| file_writer.write(data) }
        )
      end
      temp_path.rename(path)
    ensure
      temp_path&.delete if temp_path&.exist?
    end

    # A dotfile in the same directory, so that the rename stays on one filesystem
    # and globs over the content directory don't pick it up.
    def temp_path_for(path)
      path.dirname / ".#{path.basename}.#{SecureRandom.hex(8)}.part"
    end

    def preservation_client
      @preservation_client ||= Preservation::Client.configure(url: Settings.preservation_catalog.url, token: Settings.preservation_catalog.token)
    end
  end
end
