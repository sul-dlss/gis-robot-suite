server 'sul-robots1-dev.stanford.edu', user: 'lyberadmin', roles: %w{web app db}
server 'sul-robots2-dev.stanford.edu', user: 'lyberadmin', roles: %w{web app db}

Capistrano::OneTimeKey.generate_one_time_key!

set :deploy_environment, 'development'
set :whenever_environment, fetch(:deploy_environment)
set :default_env, { :robot_environment => fetch(:deploy_environment) }
