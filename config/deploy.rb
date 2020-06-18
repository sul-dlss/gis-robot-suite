# frozen_string_literal: true

set :application, 'gisRobotSuite'
set :repo_url, 'https://github.com/sul-dlss/gis-robot-suite.git'

# Default branch is :master
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/opt/app/lyberadmin/gis-robot-suite'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}
set :linked_files, %w(config/honeybadger.yml config/rgeoserver_public.yml config/rgeoserver_restricted.yml)

# Default value for linked_dirs is []
set :linked_dirs, %w(log run tmp/pids config/certs config/settings config/ArcGIS)

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :honeybadger_env, fetch(:stage)

set :bundle_without, %w[development deployment].join(' ')

# Enable bundle2 style config
set :bundler2_config_use_hook, true # this is how to opt-in to bundler 2-style config. it's false by default

# update shared_configs before restarting app
before 'deploy:publishing', 'shared_configs:update'

after 'deploy:publishing', 'resque:pool:hot_swap'
