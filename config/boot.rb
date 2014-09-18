# Ensure subsequent requires search the correct local paths
$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "robots"))

require 'rubygems'
require 'bundler/setup'
require 'logger'

# Load the environment file based on Environment.  Default to development
environment = ENV['ROBOT_ENVIRONMENT'] ||= 'development'
ROBOT_ROOT = File.expand_path(File.dirname(__FILE__) + "/..")
ROBOT_LOG = Logger.new(File.join(ROBOT_ROOT, "log/#{environment}.log"))
ROBOT_LOG.level = Logger::SEV_LABEL.index(ENV['ROBOT_LOG_LEVEL']) || Logger::INFO

# Override Solrizer's logger before it gets a chance to load and pollute STDERR.
begin
  require 'solrizer'
  Solrizer.logger = ROBOT_LOG
rescue LoadError, NameError, NoMethodError
end

# Load core robot services
require 'dor-services'
require 'lyber_core'

# TODO Maybe move auto-require to just run_robot and spec_helper?

# Load any library files and all the robots
Dir["#{ROBOT_ROOT}/lib/*.rb"].each { |f| require f }
require 'robots'

# Load local environment configuration
env_file = File.expand_path(File.dirname(__FILE__) + "/./environments/#{environment}")
puts "Loading config from #{env_file}"
require env_file

# Load Resque configuration and controller
require 'resque'
begin
  if defined? REDIS_TIMEOUT
    _server, _namespace = REDIS_URL.split('/', 2)
    _host, _port, _db = _server.split(':')
    _redis = Redis.new(:host => _host, :port => _port, :thread_safe => true, :db => _db, :timeout => REDIS_TIMEOUT.to_f)
    Resque.redis = Redis::Namespace.new(_namespace, :redis => _redis)
  else
    Resque.redis = REDIS_URL
  end
end
require 'robot-controller'
