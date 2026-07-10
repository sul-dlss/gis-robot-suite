# frozen_string_literal: true

source 'https://rubygems.org'

# stanford dlss specific gems
gem 'assembly-objectfile'
gem 'cocina-models'
gem 'dor-services-client'
gem 'druid-tools'
# Temporarily pinned lyber-core on 7/10/2026 since >v9.0 lybercore has version-aware breaking changes requiring updates
# to all consumers simultaneously. See https://github.com/sul-dlss/dor-services-app/pull/6196
gem 'lyber-core', '~> 8.0' # For robots
gem 'preservation-client'

gem 'config'
gem 'csv'
gem 'honeybadger'
gem 'rake'
gem 'sidekiq', '~> 8.0'
gem 'slop' # for bin/run_robot
gem 'zeitwerk'

source 'https://gems.contribsys.com/' do
  gem 'sidekiq-pro'
end

group :development, :test do
  gem 'debug', require: false
end

group :development do
  gem 'rspec'
  gem 'rubocop', require: false
  gem 'rubocop-factory_bot'
  gem 'rubocop-rspec'
  gem 'rubocop-rspec_rails'
end

group :test do
  gem 'rspec_junit_formatter' # For circleCI
  gem 'simplecov', require: 'false'
  gem 'webmock'
end

group :deployment do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-shared_configs'
  gem 'dlss-capistrano', require: false
end

gem 'benchmark', '~> 0.5.0'
