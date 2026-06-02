#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require File.expand_path("#{File.dirname(__FILE__)}/../config/boot")
require 'fileutils'

require 'csv'

# Orchestrates the migration of GIS files and starting the workflow
class Migrator
  def self.migrate(druid:)
    new(druid:).migrate
  end

  def initialize(druid:)
    @druid = druid
  end

  def migrate
    puts "Processing #{@druid}..."
    fetch_files
    unzip
    remove_derivative_metadata
    start_workflow(open_new_object_version)
  end

  private

  def content_dir
    @content_dir ||= create_content_dir
  end

  def create_content_dir
    stage_path = GisRobotSuite.locate_druid_path(@druid, type: :stage)
    dir = File.join(stage_path, 'content')
    FileUtils.mkdir_p(dir)
    dir
  end

  def fetch_files
    fetcher = GisRobotSuite::FileFetcher.new(druid: @druid)
    ['data.zip', 'preview.jpg'].each do |filename|
      puts "  Fetching #{filename}..."
      fetcher.write_file_with_retries(filename:, location: File.join(content_dir, filename))
    end
  end

  def unzip
    zip_path = File.join(content_dir, 'data.zip')
    return unless File.exist?(zip_path)

    puts '  Unzipping data.zip...'
    system("unzip -o -q #{zip_path} -d #{content_dir}")
  end

  def remove_derivative_metadata
    locate_derivative_metadata_files(content_dir).each do |file|
      puts "  Removing derivative metadata #{file}..."
      FileUtils.rm_f(file)
    end
  end

  def locate_derivative_metadata_files(dir)
    iso19139_xml_file = Dir.glob("#{dir}/*-iso19139.xml").first
    iso19110_xml_file = Dir.glob("#{dir}/*-iso19110.xml").first
    fgdc_xml_file = Dir.glob("#{dir}/*-fgdc.xml").first

    [iso19139_xml_file, iso19110_xml_file, fgdc_xml_file].compact
  end

  def object_client
    @object_client ||= Dor::Services::Client.object("druid:#{@druid}")
  end

  def open_new_object_version
    puts '  Opening new object version...'
    cocina = object_client.version.open(description: 'Unzip data.zip')
    cocina.version
  end

  def start_workflow(version)
    puts '  Starting assembly workflow...'
    object_client.workflow('gisAssemblyWF').create(version:)
  end
end

csv_file = ARGV[0]
if csv_file.nil? || !File.exist?(csv_file)
  puts "Usage: #{$PROGRAM_NAME} <csv_file>"
  exit 1
end

CSV.foreach(csv_file, headers: true) do |row|
  druid = row['druid']
  next if druid.nil? || druid.empty?

  Migrator.migrate(druid: druid.strip)
end
