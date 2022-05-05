# frozen_string_literal: true

set :application, 'gisRobotSuite'
set :repo_url, 'https://github.com/sul-dlss/gis-robot-suite.git'

# Default branch is :main
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
set :linked_files, %w[config/honeybadger.yml tmp/resque-pool.lock]

# Default value for linked_dirs is []
set :linked_dirs, %w[log run tmp/pids config/certs config/settings config/ArcGIS]

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :honeybadger_env, fetch(:stage)

set :bundle_without, %w[development deployment].join(' ')

# update shared_configs before restarting app
before 'deploy:publishing', 'shared_configs:update'

# Prevent deployment if application ruby not installed
set :validate_ruby_on_deploy, true
