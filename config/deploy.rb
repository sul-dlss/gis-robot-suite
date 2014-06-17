# config valid only for Capistrano 3.1
lock '3.2.1'

set :rvm_type, :system
set :rvm_ruby_string, 'ruby-1.9.3-p484'

set :application, 'demo-bots'
set :repo_url, 'https://github.com/sul-dlss/demo-bots:demoWF.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/lyberadmin/demo-bots'

# Default value for :scm is :git
# set :scm, :git
set :scm, :git
# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :stages, %W(dev staging production)
set :default_stage, "dev"
set :linked_dirs, %w(log run config/environments config/certs)

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 10 do
      within release_path do
        execute :bundle, :exec, :controller, :stop
        execute :bundle, :exec, :controller, :quit
        execute :bundle, :exec, :controller, :boot
        
      end
    end
  end

  after :publishing, :restart

 end
