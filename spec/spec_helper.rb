# Make sure specs run with the definitions from local.rb
ENV['ROBOT_ENVIRONMENT'] ||= 'local'
require 'pry'
require 'rspec'
require 'simplecov'
SimpleCov.start
