# frozen_string_literal: true

module Robots
  module DorRepo
    module GisDerivative
      # Pulls all of the files from preservation into the staging area if they are not there already
      class FetchFiles < Base
        def initialize
          super('gisDerivativeWF', 'fetch-files')
        end

        # available from LyberCore::Robot: druid, bare_druid, object_workflow, object_client, cocina_object, logger
        def perform_work
          @content_dir = Pathname(File.join(GisRobotSuite.locate_druid_path(bare_druid, type: :workspace), 'content'))
          files.each do |file|
            filename = file.filename
            location = workspace_path(filename)
            location.parent.mkpath unless location.parent.directory?
            next if already_fetched?(location, file)

            raise "Unable to fetch #{filename} for #{druid}" unless file_fetcher.write_file_with_retries(filename:, location:, max_tries: 3)
          end
        end

        private

        # Whether the file in the workspace is the one the cocina describes. We compare sizes rather
        # than md5s: the files we need to catch are empty or truncated, which a size check finds, and
        # an md5 would mean reading every original in full on every run (most often to confirm the
        # files gisAssemblyWF left), which for large GeoTIFFs on NFS can take minutes.
        def already_fetched?(location, file)
          return false unless location.file?
          return true if location.size == file.size

          logger.info("#{location} is #{location.size} bytes but #{file.filename} is #{file.size.inspect} bytes in cocina; fetching it again")
          false
        end

        def workspace_path(filename)
          @content_dir / filename
        end

        def file_fetcher
          @file_fetcher ||= GisRobotSuite::FileFetcher.new(druid:, logger:)
        end

        # iterate through cocina structural contains and return all relevant File objects
        def files
          cocina_object.structural.contains.flat_map do |fileset|
            preserved_files_for_fileset(fileset)
          end.compact
        end

        # filter down fileset files that are in preservation and are not derivatives
        def preserved_files_for_fileset(fileset)
          fileset.structural.contains.select do |file|
            file.administrative.sdrPreserve && (file.use.nil? || file.use == 'master')
          end
        end
      end
    end
  end
end
