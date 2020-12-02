# frozen_string_literal: true

server 'kurma-robots1-qa.stanford.edu', user: 'lyberadmin', roles: %w[web app db]

Capistrano::OneTimeKey.generate_one_time_key!

set :deploy_environment, 'qa'
set :default_env, robot_environment: fetch(:deploy_environment)
