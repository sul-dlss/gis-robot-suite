server 'sul-robots1-prod.stanford.edu', user: 'lyberadmin', roles: %w{web app db}
server 'sul-robots2-prod.stanford.edu', user: 'lyberadmin', roles: %w{web app db}

Capistrano::OneTimeKey.generate_one_time_key!

set :deploy_environment, 'production'
set :whenever_environment, fetch(:deploy_environment)
set :default_env, { :robot_environment => fetch(:deploy_environment) }
