# frozen_string_literal: true

Dor::Config.configure do
  fedora do
    url Settings.fedora.url
  end

  ssl do
    cert_file Settings.ssl.cert_file
    key_file Settings.ssl.key_file
    key_pass Settings.ssl.key_pass
  end

  solr.url Settings.solr.url
end

REDIS_URL = Settings.redis.url

# These are necessary for the gisDelivery/load-vector step which uses psql and shp2pgsql
ENV['PGDATABASE'] ||= Settings.db.database
ENV['PGHOST'] ||= Settings.db.host
ENV['PGPORT'] ||= Settings.db.port
ENV['PGUSER'] ||= Settings.db.user

ENV['ROBOT_DELAY'] = '0'
