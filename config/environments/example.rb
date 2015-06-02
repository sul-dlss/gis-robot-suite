cert_dir = File.join(File.dirname(__FILE__), '..', 'certs')

Dor::Config.configure do
  fedora do
    url 'https://localhost/fedora'
    key_pass ''
  end

  ssl do
    cert_file File.join(cert_dir, 'example.crt')
    key_file File.join(cert_dir, 'example.key')
    key_pass ''
  end

  geohydra do
    stage '/stage'
    workspace '/workspace'
    tmpdir '/tmp'
    geoserver do
      url 'http://localhost/geoserver'
    #  styledir '/var/geoserver/local/data/styles'
    end
    geowebcache do
      user 'example_user'
      password 'example_password'
      url 'https://localhost/geoserver/gwc'
    end
    geotiff do
      host 'localhost'
      dir '/geotiff'
    end
    postgis do
      schema 'druid'
    end
    solr do
      url 'https://localhost/solr'
      collection 'example'
    end
    opengeometadata do
      dir '/opengeometadata'
    end
  end

  stacks do
    url 'http://localhost/stacks'
  end

  purl do
    url 'http://localhost/purl'
  end


  solrizer.url 'https://localhost/solr/solrizer'
  workflow.url 'https://localhost/workflow/'
  dor_services.url 'https://localhost/dor'
end

REDIS_URL = 'localhost:6379/resque:development'

ENV['PGDATABASE'] ||= 'example_db'
ENV['PGHOST'] ||= 'localhost'
ENV['PGPORT'] ||= '5432'
ENV['PGUSER'] ||= 'example_user'

ENV['RGEOSERVER_CONFIG'] ||= File.expand_path(File.join(File.dirname(__FILE__), ENV['ROBOT_ENVIRONMENT'] + '_rgeoserver.yml'))
