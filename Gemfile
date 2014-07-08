source 'https://rubygems.org'

gem 'addressable', "2.3.5"    # pin to avoid RDF bug
gem 'dor-services', '~> 4.8'
gem 'lyber-core', '~> 3.2', '>=3.2.1'
gem 'net-ssh-krb'             # for Stanford SSH environment
gem 'robot-controller', '~> 0.3', '>= 0.3.6' # requires Resque
gem 'pry' # for console

group :development do
  source 'http://sul-gems.stanford.edu'
  if File.exists?(mygems = File.join(ENV['HOME'],'.gemfile'))
    instance_eval(File.read(mygems))
  end
  gem 'rspec'
  gem 'awesome_print'
	gem 'debugger', :platform => :ruby_19
	gem 'yard'
	gem 'capistrano', '~> 3.2.1'
  gem 'capistrano-bundler', '~> 1.1'
  gem 'lyberteam-capistrano-devel', '3.0.0.pre1'
  gem 'holepicker', '~> 0.3', '>= 0.3.3'
  gem 'capistrano-one_time_key'
end
