# frozen_string_literal: true

module GisRobotSuite
  VECTOR_TYPES = %w[application/x-esri-shapefile application/geo+json].freeze

  def self.vector?(cocina_object)
    VECTOR_TYPES.include? media_type(cocina_object)
  end

  RASTER_TYPES = %w[image/tiff].freeze

  def self.raster?(cocina_object)
    RASTER_TYPES.include?(media_type(cocina_object))
  end

  def self.media_type(cocina_object)
    geographic_form(cocina_object, 'media type')
  end

  def self.layertype(cocina_object)
    if vector?(cocina_object)
      'PostGIS'
    elsif raster?(cocina_object)
      'GeoTIFF'
    else
      raise "#{cocina_object.externalIdentifier} has unknown format: #{media_type(cocina_object)}"
    end
  end

  def self.data_format(cocina_object)
    geographic_form(cocina_object, 'data format')
  end

  def self.geographic_form(cocina_object, type)
    cocina_object.description.geographic&.first&.form&.find { |form| form.type == type }&.value
  end
  private_class_method :geographic_form

  def self.locate_druid_path(druid, opts = {})
    rootdir = '.'

    # :type => :stage indicates the path to the druid in the local stage area
    # :type => :workspace indicates the path to the druid in the SDR dor workspace
    case opts[:type]
    when :stage
      rootdir = DruidTools::Druid.new(druid, Settings.geohydra.stage).path
    when :workspace
      rootdir = DruidTools::Druid.new(druid, Settings.geohydra.workspace).path
    else
      raise 'Only :stage, :workspace are supported'
    end

    raise "Missing #{rootdir}" if opts[:validate] && !File.directory?(rootdir)

    rootdir
  end

  def self.locate_esri_metadata(dir, _opts = {})
    extensions = ['.shp.xml', '.tif.xml', '.geojson.xml']

    filename = nil
    extensions.each do |ext|
      filename = Dir.glob("#{dir}/**/*#{ext}").first
      break if filename && !File.empty?(filename)
    end

    raise "Missing ESRI metadata files in #{dir}" if filename.nil? || File.empty?(filename)

    filename
  end

  def self.locate_derivative_metadata_files(dir)
    iso19139_xml_file = Dir.glob("#{dir}/*-iso19139.xml").first
    iso19110_xml_file = Dir.glob("#{dir}/*-iso19110.xml").first
    fgdc_xml_file = Dir.glob("#{dir}/*-fgdc.xml").first

    [iso19139_xml_file, iso19110_xml_file, fgdc_xml_file].compact
  end

  class SystemCommandError < StandardError; end
  class SystemCommandNonzeroExit < SystemCommandError; end
  class SystemCommandExecutionError < SystemCommandError; end

  # @param [String] cmd the command string (including args) to run
  # @param [Logger] logger a Ruby Logger instance (e.g. the Sidekiq::Logger returned by LyberCore::Robot#logger)
  # @return [Hash<Symbol => [String, Integer, Boolean]>] cmd_result
  #   * cmd: the command string that was run
  #   * stdout_str, stderr_str: the contents, respectively, of stdout and stderr from command execution
  #   * exitstatus: the integer exit code from command execution (in practice likely always 0 if no error is raised)
  #   * success: boolean indicating whether execution was successful (in practice likely always true if no error is raised)
  # @raise [SystemCommandExecutionError, SystemCommandNonzeroExit] if the command does not execute cleanly
  def self.run_system_command(cmd, logger:)
    logger.info "#{name}.#{__method__}: Attempting to execute system command: '#{cmd}'"

    stdout_str, stderr_str, status =
      begin
        Open3.capture3(cmd)
      rescue StandardError => e
        err_msg = "Error executing system command: '#{cmd}' raised #{e}"
        logger.error "#{name}.#{__method__}: #{err_msg}"
        raise SystemCommandExecutionError, err_msg
      end

    cmd_result = { cmd:, stdout_str:, stderr_str:, exitstatus: status.exitstatus, success: status.success? }

    unless status.success? && status.exitstatus.zero?
      err_msg = "Unsuccessful attempt executing system command: result=#{cmd_result}"
      logger.error "#{name}.#{__method__}: #{err_msg}"
      raise SystemCommandNonzeroExit, err_msg
    end

    logger.info "#{name}.#{__method__}: Successfully executed system command: '#{cmd}'"
    logger.debug "#{name}.#{__method__}: System command result: #{cmd_result}"
    cmd_result
  end
end
