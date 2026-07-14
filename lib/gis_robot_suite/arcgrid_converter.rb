# frozen_string_literal: true

require 'find'
require 'shellwords'

module GisRobotSuite
  # Converts the ArcGRID in an object's workspace to a GeoTIFF and replaces the
  # ArcGRID files in Cocina. The caller is responsible for version management.
  class ArcgridConverter
    GEOTIFF_MIMETYPE = 'image/tiff; application=geotiff'

    def initialize(druid:, logger: nil)
      @bare_druid = druid.delete_prefix('druid:')
      @logger = logger || Logger.new($stdout)
    end

    def self.run(druid:, logger: nil)
      new(druid:, logger:).run
    end

    def run
      logger.info "Processing druid:#{bare_druid}..."

      convert
      copy_metadata

      logger.info '  Saving updated Cocina object...'
      object_client.update(params: replace_arcgrid_files)
      logger.info "  Successfully converted druid:#{bare_druid} to #{output_path.basename}."
    rescue StandardError => e
      logger.error "  Failed to process druid:#{bare_druid}: #{e.message}"
      raise
    end

    private

    attr_reader :bare_druid, :logger

    def object_client
      @object_client ||= Dor::Services::Client.object("druid:#{bare_druid}")
    end

    def cocina_object
      @cocina_object ||= object_client.find
    end

    def content_dir
      @content_dir ||= Pathname(GisRobotSuite.locate_druid_path(bare_druid, type: :stage)) / 'content'
    end

    def grid_dir
      return @grid_dir if defined?(@grid_dir)

      raise "Workspace content directory does not exist: #{content_dir}" unless content_dir.directory?

      grid_dirs = Find.find(content_dir).filter_map do |path|
        next unless File.file?(path) && File.basename(path).casecmp?('hdr.adf')

        Pathname(path).dirname
      end.uniq

      raise "No ArcGRID found in #{content_dir}" if grid_dirs.empty?
      raise "Multiple ArcGRID directories found in #{content_dir}: #{grid_dirs.join(', ')}" if grid_dirs.many?

      @grid_dir = grid_dirs.first
    end

    def output_path
      @output_path ||= content_dir / "#{grid_dir.basename}.tif"
    end

    def metadata_output_path
      @metadata_output_path ||= Pathname("#{output_path}.xml")
    end

    def world_file_path
      @world_file_path ||= output_path.sub_ext('.tfw')
    end

    def convert
      logger.info "  Converting #{grid_dir.basename} to #{output_path.basename}..."
      command = [
        "#{Settings.gdal_path}gdal_translate",
        '-of', 'GTiff',
        '-co', 'COMPRESS=LZW',
        '-co', 'TFW=YES',
        grid_dir.to_s,
        output_path.to_s
      ].shelljoin
      GisRobotSuite.run_system_command(command, logger:)
      raise "gdal_translate failed to create #{output_path}" unless output_path.size?
      raise "gdal_translate failed to create #{world_file_path}" unless world_file_path.size?
    end

    def replace_arcgrid_files
      source_file_set, source_file = find_source
      raise "No Cocina files match the ArcGRID in #{grid_dir}" unless source_file_set

      new_file_sets = cocina_object.structural.contains.map do |file_set|
        retained_files = file_set.structural.contains.reject { |file| grid_filenames.include?(file.filename) }
        next file_set if retained_files.size == file_set.structural.contains.size

        if file_set.externalIdentifier == source_file_set.externalIdentifier
          retained_files << replacement_file(source_file:, path: output_path, mimetype: GEOTIFF_MIMETYPE)
          retained_files << replacement_file(source_file:, path: world_file_path, mimetype: 'text/plain')
          retained_files << replacement_file(source_file: metadata_source_file || source_file, path: metadata_output_path, mimetype: 'application/xml')
        end
        file_set.new(structural: file_set.structural.new(contains: retained_files))
      end

      cocina_object.new(structural: cocina_object.structural.new(contains: new_file_sets))
    end

    def copy_metadata
      source_path = grid_dir / 'metadata.xml'
      raise "Missing ArcGRID metadata file: #{source_path}" unless source_path.file?

      FileUtils.cp(source_path, metadata_output_path)
    end

    def grid_filenames
      @grid_filenames ||= Find.find(grid_dir).filter_map do |path|
        next unless File.file?(path)

        relative_path = Pathname(path).relative_path_from(content_dir).to_s
        [relative_path, File.basename(path)]
      end.flatten.to_set
    end

    def find_source
      cocina_object.structural.contains.each do |file_set|
        source_file = file_set.structural.contains.find { |file| grid_filenames.include?(file.filename) }
        return [file_set, source_file] if source_file
      end
      nil
    end

    def metadata_source_file
      @metadata_source_file ||= cocina_object.structural.contains.flat_map { |file_set| file_set.structural.contains }.find do |file|
        File.basename(file.filename) == 'metadata.xml'
      end
    end

    def replacement_file(source_file:, path:, mimetype:)
      objectfile = Assembly::ObjectFile.new(path.to_s)
      params = GisRobotSuite::FileParamBuilder.build(
        objectfile:,
        file_access: source_file.access.to_h,
        version: cocina_object.version,
        mimetype:,
        use: source_file.use,
        preserve: source_file.administrative.sdrPreserve
      )
      Cocina::Models::File.new(params)
    end
  end
end
