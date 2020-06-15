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

  workflow do
    url Settings.workflow.url
    logfile Settings.workflow.logfile
    shift_age Settings.workflow.shift_age
  end
end

REDIS_URL = Settings.redis.url

ENV['PGDATABASE'] ||= Settings.db.database
ENV['PGHOST'] ||= Settings.db.host
ENV['PGPORT'] ||= Settings.db.port
ENV['PGUSER'] ||= Settings.db.user

ENV['RGEOSERVER_CONFIG'] ||= File.expand_path(File.join(File.dirname(__FILE__), "rgeoserver.yml"))

ENV['ROBOT_DELAY'] = '0'
