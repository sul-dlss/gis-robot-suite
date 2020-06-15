cert_dir = File.join(File.dirname(__FILE__), '..', 'certs')

Dor::Config.configure do
  fedora do
    url 'https://localhost/fedora'
  end

  ssl do
    cert_file File.join(cert_dir, 'example.crt')
    key_file File.join(cert_dir, 'example.key')
    key_pass ''
  end

  solrizer.url 'https://localhost/solr/solrizer'
end

REDIS_URL = 'localhost:6379/resque:development'

# These are necessary for the gisDelivery/load-vector step which uses psql and shp2pgsql
ENV['PGDATABASE'] ||= 'example_db'
ENV['PGHOST'] ||= 'localhost'
ENV['PGPORT'] ||= '5432'
ENV['PGUSER'] ||= 'example_user'

ENV['RGEOSERVER_CONFIG'] ||= File.expand_path(File.join(File.dirname(__FILE__), ENV['ROBOT_ENVIRONMENT'] + '_rgeoserver.yml'))
