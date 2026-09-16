# frozen_string_literal: true

require 'json'
require 'shellwords'

module Robots
  module DorRepo
    module GisDerivative
      # Creates derivatives for GIS data files and adds them to the cocina object.
      class CreateDerivatives < Base
        GEOTIFF_MIME_TYPE = 'image/tiff; application=geotiff'
        COG_MIME_TYPE = 'image/tiff; application=geotiff; profile=cloud-optimized'
        GEOJSON_MIME_TYPE = 'application/geo+json'
        PMTILES_MIME_TYPE = 'application/vnd.pmtiles'
        SHAPEFILE_MIME_TYPE = 'application/vnd.shp'
        FGB_MIME_TYPE = 'application/vnd.fgb'
        JP2_MIME_TYPE = 'image/jp2'
        RASTER_MIME_TYPES = [GEOTIFF_MIME_TYPE].freeze
        VECTOR_MIME_TYPES = [SHAPEFILE_MIME_TYPE, GEOJSON_MIME_TYPE].freeze
        MASTER_MIME_TYPES = RASTER_MIME_TYPES + VECTOR_MIME_TYPES
        DERIVATIVE_MIME_TYPES = [COG_MIME_TYPE, PMTILES_MIME_TYPE, FGB_MIME_TYPE, JP2_MIME_TYPE].freeze

        def initialize
          super('gisDerivativeWF', 'create-derivatives')
        end

        # available from LyberCore::Robot: druid, bare_druid, object_workflow, object_client, cocina_object, logger
        def perform_work
          @content_dir = Pathname(File.join(GisRobotSuite.locate_druid_path(bare_druid, type: :workspace), 'content'))

          cocina_object.structural.contains.each do |file_set|
            sources = source_files(file_set)
            next if sources.empty?

            sources.each do |cocina_file|
              filepath = workspace_path(cocina_file.filename)
              raise "Unable to find #{cocina_file.filename} in the workspace" unless File.exist?(filepath)

              create_derivatives_for_cocina_file(cocina_file, file_set)
            end

            create_thumbnail(sources.first, file_set)
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
          cog = cog_filename(cocina_file.filename)
          return if retain_existing?(filename: cog, use: 'derivative', mimetype: COG_MIME_TYPE, file_set:)

          create_cog(cocina_file.filename)
          store_derivative(filename: cog, use: 'derivative', mimetype: COG_MIME_TYPE, file_set:)
        end

        def create_vector_derivatives(cocina_file, file_set)
          fgb = fgb_filename(cocina_file.filename)
          return if retain_existing?(filename: fgb, use: 'derivative', mimetype: FGB_MIME_TYPE, file_set:)

          pmtiles = pmtiles_filename(cocina_file.filename)
          generate_vector_derivatives(cocina_file.filename)
          store_derivative(filename: fgb, use: 'derivative', mimetype: FGB_MIME_TYPE, file_set:)
          store_derivative(filename: pmtiles, use: 'derivative', mimetype: PMTILES_MIME_TYPE, file_set:)
        end

        # A file set carries a single thumbnail, so this runs once for the file set -- off its first
        # source file -- rather than once per source the way the data derivatives do. Generating one
        # per source would have each discard the record the last one just wrote, leaving every JP2
        # but the final one on disk and unrecorded.
        def create_thumbnail(cocina_file, file_set)
          # Discard an existing JP2 thumbnail if there is one and SDR created it (not provided by the user)
          updater.remove_files(use: 'thumbnail', mimetype: JP2_MIME_TYPE, file_set:)
          return if updater.has_file?(use: 'thumbnail', file_set:, mimetype: JP2_MIME_TYPE)

          jp2 = jp2_filename(cocina_file.filename)
          create_preview_jp2(cocina_file.filename, preview_generator_for(cocina_file))
          store_derivative(filename: jp2, use: 'thumbnail', mimetype: JP2_MIME_TYPE, file_set:,
                           presentation: jp2_presentation(workspace_path(jp2)))
        end

        def preview_generator_for(cocina_file)
          raster?(cocina_file) ? GisRobotSuite::RasterPreviewGenerator : GisRobotSuite::VectorPreviewGenerator
        end

        # Whether we should keep an existing derivative instead of re-generating it
        def retain_existing?(filename:, use:, mimetype:, file_set:)
          existing = updater.find_file(filename:, file_set:)
          return false if existing.nil?
          return true if existing.use == use && existing.hasMimeType == mimetype && !existing.sdrGeneratedText

          logger.info("create-derivatives: regenerating #{filename}, which the object already records " \
                      "as use: #{existing.use.inspect}, mimetype: #{existing.hasMimeType.inspect}")
          false
        end

        # Add a generated derivative to the structural metadata
        def store_derivative(filename:, use:, mimetype:, file_set:, presentation: nil)
          updater.remove_file(filename:, file_set:)
          updater.add_file(filename: workspace_path(filename), use:, mimetype:, preserve: false, file_set:, presentation:)
        end

        def raster?(cocina_file)
          RASTER_MIME_TYPES.include? cocina_file.hasMimeType
        end

        def vector?(cocina_file)
          VECTOR_MIME_TYPES.include?(cocina_file.hasMimeType)
        end

        # Filenames for the derivatives generated from a given source file
        def basename(filename) = File.basename(filename, File.extname(filename))
        def cog_filename(filename) = "#{basename(filename)}_cog.tif"
        def fgb_filename(filename) = "#{basename(filename)}.fgb"
        def pmtiles_filename(filename) = "#{basename(filename)}.pmtiles"
        def jp2_filename(filename) = "#{basename(filename)}.jp2"

        # Make derivative COG file of the master file in location and add it to cocina_object
        def create_cog(filename)
          GisRobotSuite::CogGenerator.generate(input_path: workspace_path(filename),
                                               output_path: workspace_path(cog_filename(filename)),
                                               unit: vertical_crs&.unit_label, logger: logger)
        end

        # Generate vertical CRS info from the ESRI XML metadata, if present
        def vertical_crs
          return @vertical_crs if defined?(@vertical_crs)

          esri_metadata_file = GisRobotSuite.locate_esri_metadata(@content_dir)
          @vertical_crs = GisRobotSuite::EsriVerticalCrs.new(Nokogiri::XML(File.read(esri_metadata_file)))
        rescue RuntimeError
          @vertical_crs = nil
        end

        def create_preview_jp2(filename, klass)
          klass.generate(input_path: workspace_path(filename), output_path: workspace_path(jp2_filename(filename)), logger: logger)
        end

        def generate_vector_derivatives(filename)
          # Legacy ESRI shapefiles were frequently accessioned without a .prj, leaving the data with
          # no projection to reproject from; the one the descriptive metadata records stands in.
          GisRobotSuite::VectorDerivativeGenerator.generate(input_path: workspace_path(filename),
                                                            fgb_path: workspace_path(fgb_filename(filename)),
                                                            pmtiles_path: workspace_path(pmtiles_filename(filename)),
                                                            fallback_crs: GisRobotSuite.map_projection(cocina_object), logger: logger)
        end

        def jp2_presentation(path)
          result = GisRobotSuite.run_system_command("gdalinfo -json #{Shellwords.escape(path.to_s)}", logger: logger)
          width, height = JSON.parse(result[:stdout_str])['size']
          { height:, width: }
        end

        def workspace_path(filename)
          @content_dir / filename
        end

        # Files that should be used as the source for derivatives. Checks filenames,
        # not just MIME types: COGs come in from preassembly (if re-accessioned) with
        # the same MIME type as a regular geotiff, so we have to prevent duplicating them.
        def source_files(file_set)
          masters = file_set.structural.contains.reject { |cocina_file| skip_cocina_file?(cocina_file) }
          generated = masters.flat_map { |cocina_file| derivative_filenames(cocina_file) }

          masters.reject { |cocina_file| generated.include?(cocina_file.filename) }
        end

        # The filenames of derivatives that would be generated for a given file.
        def derivative_filenames(cocina_file)
          filename = cocina_file.filename
          return [cog_filename(filename), jp2_filename(filename)] if raster?(cocina_file)

          [fgb_filename(filename), pmtiles_filename(filename), jp2_filename(filename)]
        end

        def skip_cocina_file?(cocina_file)
          !cocina_file.administrative.sdrPreserve ||
            (cocina_file.use && cocina_file.use != 'master') ||
            MASTER_MIME_TYPES.exclude?(cocina_file.hasMimeType)
        end
      end
    end
  end
end
