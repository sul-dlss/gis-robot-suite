#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require File.expand_path("#{File.dirname(__FILE__)}/../config/boot")
require 'csv'

input_file = File.expand_path('derivative-error.csv', __dir__)

CSV.foreach(input_file, headers: true) do |row|
  druid = row['Druid']
  next if druid.nil? || druid.empty?

  GisRobotSuite::OvrMimetypeUpdater.run(druid: druid.strip)
end
