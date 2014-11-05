source 'https://rubygems.org'

gem 'addressable', '2.3.5'      # pin to avoid RDF bug
gem 'assembly-objectfile', '~> 1.6.4'
gem 'dor-services', '~> 4.8'
gem 'fastimage', '~> 1.6.3'
gem 'lyber-core', '~> 3.2', '>=3.2.4'
gem 'pry', '~> 0.10.0'          # for bin/console
gem 'rake', '~> 10.3.2'
gem 'robot-controller', '~> 1.0' # requires Resque
gem 'slop', '~> 3.5.0'          # for bin/run_robot
gem 'rsolr', '~> 1.0.10'
gem 'rgeoserver', '~> 0.7.1'
gem 'ffi-geos', '~> 1.0.0'

group :development do
  if File.exists?(mygems = File.join(ENV['HOME'],'.gemfile'))
    instance_eval(File.read(mygems))
  end
  gem 'rspec'
  gem 'awesome_print'
	gem 'debugger', :platform => :ruby_19
	gem 'yard'
	gem 'capistrano', '~> 3.2.1'
  gem 'capistrano-bundler', '~> 1.1'
  gem 'capistrano-rvm', '~> 0.1.1'
  gem 'lyberteam-capistrano-devel', "~> 3.0"
  gem 'holepicker', '~> 0.3', '>= 0.3.3'
end
