# frozen_string_literal: true

# Ensure subsequent requires search the correct local paths
$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'logger'

# Load the environment file based on Environment.  Default to development
environment = ENV['ROBOT_ENVIRONMENT'] ||= 'development'
ROBOT_ROOT = File.expand_path("#{File.dirname(__FILE__)}/..")
ROBOT_LOG = Logger.new(File.join(ROBOT_ROOT, "log/#{environment}.log"))
ROBOT_LOG.level = Logger::SEV_LABEL.index(ENV['ROBOT_LOG_LEVEL']) || Logger::INFO

loader = Zeitwerk::Loader.new
loader.push_dir(File.absolute_path("#{__FILE__}/../../lib"))
loader.setup

# Load core robot services
LyberCore::Log.set_level(ROBOT_LOG.level)

Config.setup do |config|
  # Name of the constant exposing loaded settings
  config.const_name = 'Settings'
  # Load environment variables from the `ENV` object and override any settings defined in files.
  #
  config.use_env = true

  # Define ENV variable prefix deciding which variables to load into config.
  #
  config.env_prefix = 'SETTINGS'

  # What string to use as level separator for settings loaded from ENV variables. Default value of '.' works well
  # with Heroku, but you might want to change it for example for '__' to easy override settings from command line, where
  # using dots in variable names might not be allowed (eg. Bash).
  #
  config.env_separator = '__'
end

Config.load_and_set_settings(
  Config.setting_files(File.expand_path(__dir__), environment)
)

# Load local environment configuration
env_file = File.expand_path(File.dirname(__FILE__) + "/./environments/#{environment}")
puts "Loading config from #{env_file}"
require env_file

module GisRobotSuite
  def self.connect_dor_services_app
    Dor::Services::Client.configure(url: Settings.dor_services.url,
                                    token: Settings.dor_services.token)
  end
end

GisRobotSuite.connect_dor_services_app

# Load Resque configuration and controller

if defined? REDIS_TIMEOUT
  _server, _namespace = REDIS_URL.split('/', 2)
  _host, _port, _db = _server.split(':')
  _redis = Redis.new(host: _host, port: _port, db: _db, timeout: REDIS_TIMEOUT.to_f)
  Resque.redis = Redis::Namespace.new(_namespace, redis: _redis)
else
  Resque.redis = REDIS_URL
end
