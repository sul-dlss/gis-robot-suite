# frozen_string_literal: true

require 'simplecov'
require 'webmock/rspec'

SimpleCov.start do
  track_files 'bin/**/*'
  track_files 'lib/**/*.rb'
  track_files 'robots/**/*.rb'
  add_filter '/spec/'
end

ENV['ROBOT_ENVIRONMENT'] = 'test'
require File.expand_path("#{__dir__}/../config/boot")

require 'pry'
require 'byebug'
require 'rspec'
require 'cocina/rspec'
require 'zip'
include LyberCore::Rspec # rubocop:disable Style/MixinUsage

def read_fixture(fname)
  File.read(File.join(fixture_dir, fname))
end

def fixture_dir
  @fixture_dir ||= File.join(File.dirname(__FILE__), 'fixtures')
end

# count the number of files in the given directory
def count_files(dir)
  Dir.glob("#{dir}/*").count { |file| File.file?(file) }
end
