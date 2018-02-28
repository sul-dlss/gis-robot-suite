source 'https://rubygems.org'

gem 'assembly-objectfile', '~> 1.6.6'
gem 'bundler', '~> 1.10'
gem 'dor-services', '~> 5.8', '>= 5.8.2'
gem 'fastimage', '~> 1.7'
gem 'ffi-geos', '~> 1.0'          # XXX: where is this used?
gem 'lyber-core', '~> 4.0', '>= 4.0.3'
gem 'pry', '~> 0.10'              # for console
gem 'rake'
gem 'rgeoserver', '~> 0.10'
gem 'robot-controller', '~> 2.0', '>= 2.0.4'  # requires Resque
gem 'rsolr'
gem 'slop', '~> 3.6'              # for bin/run_robot
gem 'whenever', '~> 0.9'
gem 'honeybadger'
gem 'geo_combine'

gem 'net-http-persistent', '~> 2.9.4' # TODO: https://github.com/drbrain/net-http-persistent/issues/80

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
