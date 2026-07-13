#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require File.expand_path("#{File.dirname(__FILE__)}/../config/boot")
require 'csv'

input_file = ARGV[0]
if input_file.nil? || !File.exist?(input_file)
  puts "Usage: #{$PROGRAM_NAME} <csv_file_with_druids>"
  exit 1
end

CSV.foreach(input_file, headers: true) do |row|
  druid_column = row.headers.find { |header| header&.casecmp?('druid') }
  druid = row[druid_column]&.strip
  next if druid.nil? || druid.empty?

  GisRobotSuite::ArcgridConverter.run(druid:)
end
