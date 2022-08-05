# frozen_string_literal: true

source 'https://rubygems.org'

# stanford dlss specific gems
gem 'assembly-objectfile'
gem 'dor-services-client', '~> 12.0'
gem 'dor-workflow-client', '~> 5.0'
gem 'druid-tools'
gem 'geoserver-publish', '>= 0.5.0' # samvera labs
gem 'lyber-core', '~> 6.1'
gem 'stanford-mods' # for GisDelivery::LoadGeoserver

gem 'config', '~> 3.1'
gem 'fastimage', '~> 2.2' # to get mimetype in GenerateContentMetadata
gem 'pry', '~> 0.10' # for console
gem 'rake', '~> 13.0'
gem 'rsolr'
gem 'slop', '~> 3.6' # for bin/run_robot
gem 'honeybadger'
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
  gem 'dlss-capistrano', require: false
  gem 'capistrano-shared_configs'
end
