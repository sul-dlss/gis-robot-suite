# frozen_string_literal: true

REDIS_URL = 'localhost:6379/resque:development'

# These are necessary for the gisDelivery/load-vector step which uses psql and shp2pgsql
ENV['PGDATABASE'] ||= 'example_db'
ENV['PGHOST'] ||= 'localhost'
ENV['PGPORT'] ||= '5432'
ENV['PGUSER'] ||= 'example_user'
