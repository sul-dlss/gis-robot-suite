# frozen_string_literal: true

server 'kurma-robots-qa-01.stanford.edu', user: 'lyberadmin', roles: %w[web app db]

Capistrano::OneTimeKey.generate_one_time_key!

set :deploy_environment, 'production'
set :default_env, robot_environment: fetch(:deploy_environment)
