cert_dir = File.join(File.dirname(__FILE__), "..", "certs")

Dor::Config.configure do

  solrizer.url 'http://example.com/solr'
  workflow.url 'http://example.com/workflow'
  dor_services.url 'http://example.com/dor'
  purl.url 'http://example.com/purl'

  robots do 
    workspace '/tmp'
  end
  
  fedora do
    url 'http://example.com/fedora'
  end

  ssl do
    cert_file File.join(cert_dir,"example.crt")
    key_file File.join(cert_dir,"example.key")
    key_pass ''
  end

  geohydra do
    workspace "/var/example/workspace"
    stage "/var/example/stage"
    tmpdir "/var/example/tmp"
  end

end

REDIS_URL ||= "example.com:6379/resque:development"

