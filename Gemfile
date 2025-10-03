# frozen_string_literal: true

source 'https://rubygems.org'

# stanford dlss specific gems
gem 'assembly-objectfile'
gem 'dor-services-client', '~> 15.0'
gem 'druid-tools'
gem 'geoserver-publish', '>= 0.5.0' # samvera labs
gem 'lyber-core', '~> 8.0'

gem 'config'
gem 'csv'
gem 'fastimage', '~> 2.2' # to get mimetype in GenerateStructural
gem 'honeybadger'
gem 'pry' # for console
gem 'rake'
gem 'retries'
gem 'scanf'
gem 'sidekiq', '~> 8.0'
gem 'slop' # for bin/run_robot
gem 'zeitwerk', '~> 2.1'

source 'https://gems.contribsys.com/' do
  gem 'sidekiq-pro'
end

group :development do
  gem 'debug', require: false
  gem 'rspec'
  gem 'rubocop', require: false
  gem 'rubocop-capybara'
  gem 'rubocop-factory_bot'
  gem 'rubocop-rspec'
  gem 'rubocop-rspec_rails'
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
