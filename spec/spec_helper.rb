# frozen_string_literal: true

# Make sure specs run with the definitions from local.rb
ENV['ROBOT_ENVIRONMENT'] ||= 'test'

require 'simplecov'
require 'webmock/rspec'

SimpleCov.start do
  track_files 'bin/**/*'
  track_files 'lib/**/*.rb'
  track_files 'robots/**/*.rb'
  add_filter '/spec/'
end

require_relative '../config/boot'

require 'pry'
require 'rspec'

def read_fixture(fname)
  File.read(File.join(fixture_dir, fname))
end

def fixture_dir
  @fixture_dir ||= File.join(File.dirname(__FILE__), 'fixtures')
end
