# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

loader = Zeitwerk::Loader.new
loader.push_dir(File.absolute_path("#{__FILE__}/../../lib"))
loader.setup

# GIS robots are "special" because they use environments/*.rb files.
boot = LyberCore::Boot.new(__dir__)
boot.boot_config
env_require = File.expand_path(File.dirname(__FILE__) + "/./environments/#{boot.environment}")
env_file = "#{env_require}.rb"
if File.exist?(env_file)
  puts "Loading config from #{env_file}"
  require env_require
end
boot.perform
