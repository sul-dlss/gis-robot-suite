# frozen_string_literal: true

source 'https://rubygems.org'

gem 'assembly-objectfile'
gem 'config', '~> 3.1'
gem 'dor-services-client', '~> 7.0'
gem 'dor-workflow-client', '~> 3.1'
gem 'druid-tools'
gem 'fastimage', '~> 2.2'
gem 'ffi-geos', '~> 1.0', require: false  # XXX: where is this used?
# iso-639 0.3.0 isn't compatible with ruby 2.5.  This declaration can be dropped when we upgrade to ruby 2.6
# see https://github.com/alphabetum/iso-639/issues/12
gem 'geoserver-publish', '>= 0.5.0'
gem 'iso-639', '~> 0.2.10'
gem 'lyber-core', '~> 6.1'
gem 'stanford-mods'               # for GisDelivery::LoadGeoserver
gem 'pry', '~> 0.10'              # for console
gem 'rake', '~> 13.0'
gem 'rsolr'
gem 'slop', '~> 3.6'              # for bin/run_robot
gem 'honeybadger'
gem 'geo_combine'
gem 'resque'
gem 'resque-pool'
gem 'scanf'
gem 'zeitwerk', '~> 2.1'

group :development do
  gem 'rspec'
  gem 'rubocop', require: false
  gem 'rubocop-rspec'
end

group :test do
  gem 'webmock'
  gem 'rspec_junit_formatter' # For circleCI
  gem 'simplecov', require: 'false'
end

group :deployment do
  gem 'capistrano'
  gem 'capistrano-rvm'
  gem 'capistrano-bundler'
  gem 'dlss-capistrano', '~> 3.11'
  gem 'capistrano-shared_configs'
end
