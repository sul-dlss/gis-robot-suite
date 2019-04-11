source 'https://rubygems.org'

gem 'assembly-objectfile'
gem 'dor-services', '~> 6.8'
gem 'fastimage', '~> 1.7'
gem 'ffi-geos', '~> 1.0'          # XXX: where is this used?
gem 'lyber-core', '~> 4.0', '>= 4.0.3'
gem 'pry', '~> 0.10'              # for console
gem 'rake'
gem 'rgeoserver', '~> 0.10'
gem 'robot-controller', '~> 2.0', '>= 2.0.4'  # requires Resque
gem 'rsolr'
gem 'slop', '~> 3.6'              # for bin/run_robot
gem 'whenever'
gem 'honeybadger'
gem 'geo_combine'
gem 'net-http-persistent', '~> 3.0'
gem 'activemodel', '~> 5.1', '< 5.2'  # due to https://github.com/sul-dlss/gis-robot-suite/issues/174

group :development do
  gem 'rspec'
  gem 'coveralls', require: false
  gem 'rubocop', '~> 0.52.1', require: false # avoid code churn due to rubocop changes
  gem 'rubocop-rspec'
end

group :deployment do
  gem 'capistrano'
  gem 'capistrano-rvm'
  gem 'capistrano-bundler'
  gem 'dlss-capistrano'
  gem 'capistrano-shared_configs'
end
