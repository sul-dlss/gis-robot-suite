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

# Override Solrizer's logger before it gets a chance to load and pollute
# STDERR.
begin
  require 'solrizer'
  Solrizer.logger = ROBOT_LOG
rescue LoadError, NameError, NoMethodError
end

require 'dor-services'
require 'lyber_core'

# TODO Maybe move auto-require to just run_robot and spec_helper?
Dir["#{ROBOT_ROOT}/lib/*.rb"].each { |f| require f }
require 'build_was_crawl_druid_tree'
require 'metadata_extractor'
require 'content_metadata_generator'
require 'desc_metadata_generator'
require 'technical_metadata_generator'
require 'end_was_crawl_preassembly'


env_file = File.expand_path(File.dirname(__FILE__) + "/./environments/#{environment}")
puts "Loading config from #{env_file}"
require env_file

require 'resque'
REDIS_URL ||= "sul-lyberservices-dev.stanford.edu:6379/resque:#{ENV['ROBOT_ENVIRONMENT']}"
Resque.redis = REDIS_URL

require 'active_support/core_ext' # camelcase
require 'robot-controller'
