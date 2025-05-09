# frozen_string_literal: true

server 'kurma-robots-prod-01.stanford.edu', user: 'lyberadmin', roles: %w[web app db worker]

set :deploy_environment, 'production'
set :default_env, robot_environment: fetch(:deploy_environment)
