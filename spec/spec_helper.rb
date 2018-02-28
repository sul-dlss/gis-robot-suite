# Make sure specs run with the definitions from local.rb
ENV['ROBOT_ENVIRONMENT'] ||= 'local'
require 'pry'
require 'rspec'

require 'coveralls'
Coveralls.wear!
require 'simplecov'
SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter 'spec'
end
