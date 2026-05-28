# frozen_string_literal: true

module Robots
  module DorRepo
    module GisDerivative
      # Creates derivatives for GIS data files and adds them to the cocina object.
      class CreateDerivatives < Base
        COG_MIME_TYPE = 'image/tiff; application=geotiff; profile=cloud-optimized'
        DERIVATIVE_MIME_TYPES = [COG_MIME_TYPE].freeze
        MASTER_MIME_TYPES = ['image/tiff; application=geotiff'].freeze

        def initialize
          super('gisDerivativeWF', 'create-derivatives')
        end

        # available from LyberCore::Robot: druid, bare_druid, object_workflow, object_client, cocina_object, logger
        def perform_work
          @content_dir = Pathname(File.join(GisRobotSuite.locate_druid_path(bare_druid, type: :workspace), 'content'))

          file_sets = create_derivatives
          # Save the modified metadata
          updated = cocina_object.new(structural: cocina_object.structural.new(contains: file_sets))
          object_client.update(params: updated)
        end

        private

        def create_derivatives
          file_sets = cocina_object.structural.to_h.fetch(:contains) # make this a mutable hash
          file_sets.each do |file_set|
            cocina_files = file_set.dig(:structural, :contains)

            new_cocina_files = cocina_files.dup
            cocina_files.each do |cocina_file|
              # If the cocina file is not a master file, skip it
              next if skip_cocina_file?(cocina_file)

              filepath = workspace_path(cocina_file.fetch(:filename))
              derivative_cocina_file = find_derivative_cocina_file(cocina_files)
              # If the master exists and there is no derivative file:
              #  1. delete existing derivative cocina file
              #  2. generate derivative
              #  3. add new derivative cocina file
              if File.exist?(filepath)
                new_cocina_files.delete(derivative_cocina_file) if derivative_cocina_file
                derivative_filename = create_cog(cocina_file.fetch(:filename))
                create_cocina_derivative_file(derivative_filename, new_cocina_files, COG_MIME_TYPE)
                next
              end

              raise NotImplementedError, "Unabel to find #{cocina_file.fetch(:filename)} in the workspace"
            end
            file_set[:structural][:contains] = new_cocina_files
          end

          file_sets
        end

        def find_derivative_cocina_file(cocina_files)
          cocina_files.find do |file|
            file[:use] == 'derivative' &&
              DERIVATIVE_MIME_TYPES.include?(file[:hasMimeType])
          end
        end

        def create_cog(filename)
          input = workspace_path(filename)

          basename = File.basename(filename, '.tif')
          derivative_filename = "#{basename}_cog.tif"
          output = workspace_path(derivative_filename)
          # Make derivative COG file of the master file in location and add it to cocina_object
          command = "gdal raster convert --format=COG --co TILING_SCHEME=GoogleMapsCompatible #{Shellwords.escape(input.to_s)} #{Shellwords.escape(output.to_s)}"
          GisRobotSuite.run_system_command(command, logger:)
          derivative_filename
        end

        def create_cocina_derivative_file(filename, new_cocina_files, mime_type)
          new_cocina_files << {
            type: 'https://cocina.sul.stanford.edu/models/file',
            externalIdentifier: "https://cocina.sul.stanford.edu/file/#{SecureRandom.uuid}",
            version: cocina_object.version,
            label: filename,
            filename:,
            hasMessageDigests: generate_checksums(workspace_path(filename)),
            hasMimeType: mime_type,
            use: 'derivative',
            administrative: { sdrPreserve: false, publish: true, shelve: true },
            access: file_access
          }
        end

        def file_access
          @file_access ||= cocina_object.access.to_h
                                        .slice(:view, :download, :location, :controlledDigitalLending)
                                        .tap do |access|
            access[:view] = 'dark' if access[:view] == 'citation-only'
          end
        end

        def generate_checksums(filepath)
          md5 = Digest::MD5.new
          sha1 = Digest::SHA1.new
          File.open(filepath, 'r') do |stream|
            while (buffer = stream.read(8192))
              md5.update(buffer)
              sha1.update(buffer)
            end
          end
          [{ type: 'md5', digest: md5.hexdigest }, { type: 'sha1', digest: sha1.hexdigest }]
        end

        def workspace_path(filename)
          @content_dir / filename
        end

        def skip_cocina_file?(cocina_file)
          !cocina_file.dig(:administrative, :sdrPreserve) ||
            cocina_file[:use] != 'master' ||
            MASTER_MIME_TYPES.exclude?(cocina_file.fetch(:hasMimeType))
        end
      end
    end
  end
end
