cert_dir = File.join(File.dirname(__FILE__), "..", "certs")

Dor::Config.configure do

  solrizer.url 'http://example.com/solr'
  workflow.url 'http://example.com/workflow'
  dor_services.url 'http://example.com/dor'

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
   
  geoserver do
    url "http://example.com/geoserver"	
end

  purl do
    url 'http://example.com/purl'
  end
end

# @see http://rubydoc.info/gems/redis/3.0.7/file/README.md
# @see https://github.com/resque/resque
#
# Set the redis connection. Takes any of:
#   String - a redis url string (e.g., 'redis://host:port')
#   String - 'hostname:port[:db][/namespace]'
#   Redis - a redis connection that will be namespaced :resque
#   Redis::Namespace - a namespaced redis connection that will be used as-is
#   Redis::Distributed - a distributed redis connection that will be used as-is
#   Hash - a redis connection hash (e.g. {:host => 'localhost', :port => 6379, :db => 0})
REDIS_URL = '127.0.0.1:6379/resque:development' # hostname:port[:db][/namespace]

