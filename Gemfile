# frozen_string_literal: true

source 'https://rubygems.org'

# stanford dlss specific gems
gem 'assembly-objectfile'
gem 'dor-services-client', '~> 14.0'
gem 'dor-workflow-client', '~> 7.0'
gem 'druid-tools'
gem 'geoserver-publish', '>= 0.5.0' # samvera labs
gem 'lyber-core', '~> 7.1'
gem 'stanford-mods' # for GisDelivery::LoadGeoserver

gem 'config', '~> 3.1'
gem 'fastimage', '~> 2.2' # to get mimetype in GenerateContentMetadata
gem 'pry', '~> 0.10' # for console
gem 'rake', '~> 13.0'
gem 'slop', '~> 3.6' # for bin/run_robot
gem 'honeybadger'
gem 'scanf'
gem 'sidekiq', '~> 7.0'
gem 'zeitwerk', '~> 2.1'

source 'https://gems.contribsys.com/' do
  gem 'sidekiq-pro'
end

group :development do
  gem 'rspec'
  gem 'rubocop', require: false
  gem 'rubocop-rspec'
  gem 'debug', require: false
end

group :test do
  gem 'webmock'
  gem 'rspec_junit_formatter' # For circleCI
  gem 'simplecov', require: 'false'
end

group :deployment do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'dlss-capistrano', require: false
  gem 'capistrano-shared_configs'
end
