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

gem 'config'
gem 'fastimage', '~> 2.2' # to get mimetype in GenerateStructural
gem 'honeybadger'
gem 'pry' # for console
gem 'rake'
gem 'scanf'
gem 'sidekiq', '~> 7.0'
gem 'slop' # for bin/run_robot
gem 'zeitwerk', '~> 2.1'

source 'https://gems.contribsys.com/' do
  gem 'sidekiq-pro'
end

group :development do
  gem 'debug', require: false
  gem 'rspec'
  gem 'rubocop', require: false
  gem 'rubocop-rspec'
end

group :test do
  gem 'byebug'
  gem 'rspec_junit_formatter' # For circleCI
  gem 'rubyzip'
  gem 'simplecov', require: 'false'
  gem 'webmock'
end

group :deployment do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-shared_configs'
  gem 'dlss-capistrano', require: false
end
