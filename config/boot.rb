# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

loader = Zeitwerk::Loader.new
loader.push_dir(File.absolute_path("#{__FILE__}/../../lib"))
loader.setup

boot = LyberCore::Boot.new(__dir__)
boot.boot_config
boot.perform
