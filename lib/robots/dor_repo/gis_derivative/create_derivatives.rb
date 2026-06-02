# frozen_string_literal: true

module Robots
  module DorRepo
    module GisDerivative
      # Creates derivatives for GIS data files and adds them to the cocina object.
      class CreateDerivatives < Base
        COG_MIME_TYPE = 'image/tiff; application=geotiff; profile=cloud-optimized'
        PMTILES_MIME_TYPE = 'application/vnd.pmtiles'
        FGB_MIME_TYPE = 'application/vnd.fgb'
        DERIVATIVE_MIME_TYPES = [COG_MIME_TYPE, PMTILES_MIME_TYPE, FGB_MIME_TYPE].freeze
        MASTER_MIME_TYPES = ['image/tiff; application=geotiff', 'application/vnd.shp', 'application/geo+json'].freeze

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
              raise NotImplementedError, "Unable to find #{cocina_file.fetch(:filename)} in the workspace" unless File.exist?(filepath)

              create_derivatives_for_cocina_file(cocina_file, new_cocina_files)
            end
            file_set[:structural][:contains] = new_cocina_files
          end

          file_sets
        end

        #  1. delete existing derivative cocina file
        #  2. generate derivative(s)
        #  3. add new derivative(s) to the cocina structure
        def create_derivatives_for_cocina_file(cocina_file, new_cocina_files)
          new_cocina_derivatives = if raster?(cocina_file)
                                     create_cocina_raster_derivatives(cocina_file, new_cocina_files)
                                   elsif vector?(cocina_file)
                                     create_cocina_vector_derivatives(cocina_file, new_cocina_files)
                                   end

          new_cocina_files.concat(new_cocina_derivatives)
        end

        def create_cocina_raster_derivatives(cocina_file, new_cocina_files)
          derivative_cocina_file = find_derivative_cocina_file(new_cocina_files, COG_MIME_TYPE)
          new_cocina_files.delete(derivative_cocina_file) if derivative_cocina_file
          derivative_filename = create_cog(cocina_file.fetch(:filename))
          [create_cocina_derivative_file(derivative_filename, COG_MIME_TYPE)]
        end

        def create_cocina_vector_derivatives(cocina_file, new_cocina_files)
          # Discard existing PMTile and FlatGeoBuf derivatives if they exist
          find_derivative_cocina_files(new_cocina_files, [PMTILES_MIME_TYPE, FGB_MIME_TYPE]).each do |df|
            new_cocina_files.delete(df)
          end
          fgb_filename, pmtiles_filename = create_vector_derivatives(cocina_file.fetch(:filename))
          [create_cocina_derivative_file(fgb_filename, FGB_MIME_TYPE),
           create_cocina_derivative_file(pmtiles_filename, PMTILES_MIME_TYPE)]
        end

        def find_derivative_cocina_file(cocina_files, mime_type)
          cocina_files.find do |file|
            file[:use] == 'derivative' && file[:hasMimeType] == mime_type
          end
        end

        def find_derivative_cocina_files(cocina_files, mime_types)
          cocina_files.select do |file|
            file[:use] == 'derivative' && mime_types.include?(file[:hasMimeType])
          end
        end

        def raster?(cocina_file)
          cocina_file[:hasMimeType] == 'image/tiff; application=geotiff'
        end

        def vector?(cocina_file)
          ['application/vnd.shp', 'application/geo+json'].include?(cocina_file[:hasMimeType])
        end

        def create_cog(filename)
          input = workspace_path(filename)

          basename = File.basename(filename, '.tif')
          derivative_filename = "#{basename}_cog.tif"
          output = workspace_path(derivative_filename)
          # Make derivative COG file of the master file in location and add it to cocina_object
          GisRobotSuite::CogGenerator.generate(input_path: input, output_path: output, logger: logger)
          derivative_filename
        end

        def create_vector_derivatives(filename)
          input = workspace_path(filename)
          basename = File.basename(filename, File.extname(filename))
          fgb_filename = "#{basename}.fgb"
          fgb_output = workspace_path(fgb_filename)
          pmtiles_filename = "#{basename}.pmtiles"
          pmtiles_output = workspace_path(pmtiles_filename)

          GisRobotSuite::VectorDerivativeGenerator.generate(input_path: input, fgb_path: fgb_output, pmtiles_path: pmtiles_output, logger: logger)

          [fgb_filename, pmtiles_filename]
        end

        def create_cocina_derivative_file(filename, mimetype)
          objectfile = Assembly::ObjectFile.new(workspace_path(filename))
          GisRobotSuite::FileParamBuilder.build(objectfile:, file_access:, version:, mimetype:, use: 'derivative', preserve: false)
        end

        delegate :version, to: :cocina_object

        def file_access
          @file_access ||= cocina_object.access.to_h
                                        .slice(:view, :download, :location, :controlledDigitalLending)
                                        .tap do |access|
            access[:view] = 'dark' if access[:view] == 'citation-only'
          end
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
