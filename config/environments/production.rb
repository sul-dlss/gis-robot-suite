# frozen_string_literal: true

# These are necessary for the gisDelivery/load-vector step which uses psql and shp2pgsql
ENV['PGDATABASE'] ||= Settings.db.database
ENV['PGHOST'] ||= Settings.db.host
ENV['PGPORT'] ||= Settings.db.port
ENV['PGUSER'] ||= Settings.db.user
