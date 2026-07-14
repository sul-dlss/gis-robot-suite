#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require File.expand_path("#{File.dirname(__FILE__)}/../config/boot")

input_file = ARGV[0]
if input_file.nil? || !File.exist?(input_file)
  puts "Usage: #{$PROGRAM_NAME} <file_with_druids>"
  exit 1
end

process_druid = lambda do |druid|
  druid = druid&.strip
  next if druid.nil? || druid.empty?

  GisRobotSuite::SubdirectoryFileRemover.run(druid:)
end

# Handle either a CSV file with a "druid" column or plain text with one druid per line.
if input_file.end_with?('.csv')
  require 'csv'
  CSV.foreach(input_file, headers: true) { |row| process_druid.call(row['druid']) }
else
  File.foreach(input_file) do |line|
    druid = line.strip
    next if druid.empty? || druid.start_with?('#')

    process_druid.call(druid)
  end
end
