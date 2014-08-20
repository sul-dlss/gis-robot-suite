Dor::Config.configure do

  workflow.url 'https://example.com/workflow/'

  robots do 
    workspace '/tmp'
  end
  
  demoConfig do
    
  end

  dor do
    service_root 'https://USERNAME:PASSWORD@example.com/dor/v1'
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
