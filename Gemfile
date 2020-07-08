# frozen_string_literal: true

source 'https://rubygems.org'

gem 'assembly-objectfile'
gem 'config', '~> 2.0'
gem 'dor-services', '~> 9.5'
gem 'dor-services-client', '~> 6.6'
gem 'dor-workflow-client', '~> 3.1'
gem 'druid-tools'
gem 'fastimage', '~> 1.7'
gem 'ffi-geos', '~> 1.0', require: false  # XXX: where is this used?
# iso-639 0.3.0 isn't compatible with ruby 2.5.  This declaration can be dropped when we upgrade to ruby 2.6
# see https://github.com/alphabetum/iso-639/issues/12
gem 'geoserver-publish', '>= 0.4.0'
gem 'iso-639', '~> 0.2.10'
gem 'lyber-core', '~> 6.1'
gem 'pry', '~> 0.10'              # for console
gem 'rake', '~> 13.0'
gem 'rsolr'
gem 'slop', '~> 3.6'              # for bin/run_robot
gem 'honeybadger'
gem 'geo_combine'
gem 'net-http-persistent', '~> 3.0'
gem 'resque'
gem 'resque-pool'
gem 'scanf'
gem 'zeitwerk', '~> 2.1'

group :development do
  gem 'rspec'
  gem 'coveralls', require: false
  gem 'rubocop', require: false
  gem 'rubocop-rspec'
end

group :test do
  gem 'webmock'
end

group :deployment do
  gem 'capistrano'
  gem 'capistrano-rvm'
  gem 'capistrano-bundler'
  gem 'capistrano-resque-pool'
  gem 'dlss-capistrano'
  gem 'capistrano-shared_configs'
end
