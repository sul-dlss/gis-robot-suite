#!/usr/bin/env ruby
# frozen_string_literal: true

# Get the druid list from https://argo.stanford.edu/catalog?f%5Bcontent_file_mimetypes_ssimdv%5D%5B%5D=image%2Ftiff&f%5Bcontent_type_ssimdv%5D%5B%5D=geo

require 'bundler/setup'
require File.expand_path("#{File.dirname(__FILE__)}/../config/boot")

input_file = ARGV[0]
if input_file.nil? || !File.exist?(input_file)
  puts "Usage: #{$PROGRAM_NAME} <file_with_druids>"
  exit 1
end

# Handle either CSV file or a plain text file with one druid per line
if input_file.end_with?('.csv')
  require 'csv'
  CSV.foreach(input_file, headers: true) do |row|
    druid = row['druid']
    next if druid.nil? || druid.empty?

    GisRobotSuite::GeotiffMimetypeUpdater.run(druid: druid.strip)
  end
else
  File.readlines(input_file).each do |line|
    druid = line.strip
    next if druid.empty? || druid.start_with?('#')

    GisRobotSuite::GeotiffMimetypeUpdater.run(druid: druid)
  end
end
