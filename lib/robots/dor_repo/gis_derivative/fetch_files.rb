# frozen_string_literal: true

module Robots
  module DorRepo
    module GisDerivative
      # Pulls all of the master object files from preservation into the staging area if they are not there already
      class FetchFiles < Base
        def initialize
          super('gisDerivativeWF', 'fetch-files')
        end

        # available from LyberCore::Robot: druid, bare_druid, object_workflow, object_client, cocina_object, logger
        def perform_work
          @content_dir = Pathname(File.join(GisRobotSuite.locate_druid_path(bare_druid, type: :workspace), 'content'))
          master_filenames.each do |filename|
            location = workspace_path(filename)
            location.parent.mkpath unless location.parent.directory?
            next if location.exist?

            raise "Unable to fetch #{filename} for #{druid}" unless file_fetcher.write_file_with_retries(filename:, location:, max_tries: 3)
          end
        end

        private

        def workspace_path(filename)
          @content_dir / filename
        end

        def file_fetcher
          @file_fetcher ||= GisRobotSuite::FileFetcher.new(druid:, logger:)
        end

        # return a list of filenames that are the master files for the object
        # iterate over all files in cocina_object.structural.contains, looking at mimetypes
        # return a list of filenames that are correct mimetype
        def master_filenames
          @master_filenames ||= files.map(&:filename)
        end

        # iterate through cocina structural contains and return all relevant File objects
        def files
          cocina_object.structural.contains.flat_map do |fileset|
            preserved_files_for_fileset(fileset)
          end.compact
        end

        # filter down fileset files that are in preservation and have the master role
        def preserved_files_for_fileset(fileset)
          fileset.structural.contains.select do |file|
            file.administrative.sdrPreserve &&
              file.use == 'master'
          end
        end
      end
    end
  end
end
