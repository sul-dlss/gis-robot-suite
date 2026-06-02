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

          cocina_object.structural.contains.each do |file_set|
            file_set.structural.contains.each do |cocina_file|
              next if skip_cocina_file?(cocina_file)

              filepath = workspace_path(cocina_file.filename)
              raise NotImplementedError, "Unable to find #{cocina_file.filename} in the workspace" unless File.exist?(filepath)

              create_derivatives_for_cocina_file(cocina_file, file_set)
            end
          end

          object_client.update(params: updater.cocina_object)
        end

        private

        def updater
          @updater ||= GisRobotSuite::StructuralUpdator.new(cocina_object)
        end

        def create_derivatives_for_cocina_file(cocina_file, file_set)
          if raster?(cocina_file)
            create_raster_derivatives(cocina_file, file_set)
          elsif vector?(cocina_file)
            create_vector_derivatives(cocina_file, file_set)
          end
        end

        def create_raster_derivatives(cocina_file, file_set)
          # Discard existing COG derivative if it exists
          updater.remove_files(use: 'derivative', mimetype: COG_MIME_TYPE, file_set:)

          derivative_filename = create_cog(cocina_file.filename)
          updater.add_file(filename: workspace_path(derivative_filename), use: 'derivative', preserve: false, file_set:, mimetype: COG_MIME_TYPE)
        end

        def create_vector_derivatives(cocina_file, file_set)
          # Discard existing PMTile and FlatGeoBuf derivatives if they exist
          updater.remove_files(use: 'derivative', mimetype: PMTILES_MIME_TYPE, file_set:)
          updater.remove_files(use: 'derivative', mimetype: FGB_MIME_TYPE, file_set:)

          fgb_filename, pmtiles_filename = generate_vector_derivatives(cocina_file.filename)
          updater.add_file(filename: workspace_path(fgb_filename), use: 'derivative', preserve: false, file_set:, mimetype: FGB_MIME_TYPE)
          updater.add_file(filename: workspace_path(pmtiles_filename), use: 'derivative', preserve: false, file_set:, mimetype: PMTILES_MIME_TYPE)
        end

        def raster?(cocina_file)
          cocina_file.hasMimeType == 'image/tiff; application=geotiff'
        end

        def vector?(cocina_file)
          ['application/vnd.shp', 'application/geo+json'].include?(cocina_file.hasMimeType)
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

        def generate_vector_derivatives(filename)
          input = workspace_path(filename)
          basename = File.basename(filename, File.extname(filename))
          fgb_filename = "#{basename}.fgb"
          fgb_output = workspace_path(fgb_filename)
          pmtiles_filename = "#{basename}.pmtiles"
          pmtiles_output = workspace_path(pmtiles_filename)

          GisRobotSuite::VectorDerivativeGenerator.generate(input_path: input, fgb_path: fgb_output, pmtiles_path: pmtiles_output, logger: logger)

          [fgb_filename, pmtiles_filename]
        end

        def workspace_path(filename)
          @content_dir / filename
        end

        def skip_cocina_file?(cocina_file)
          !cocina_file.administrative.sdrPreserve ||
            cocina_file.use != 'master' ||
            MASTER_MIME_TYPES.exclude?(cocina_file.hasMimeType)
        end
      end
    end
  end
end
