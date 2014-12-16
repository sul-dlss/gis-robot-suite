#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../config/boot')

Dir.glob("/var/geomdtk/current/stage/00_druids*").each do |fn|
  File.open(fn, 'rb').readlines.each do |druid|
    druid.strip!
    puts "Processing #{druid}"
    i = Dor::Item.find("druid:#{druid}")
    i.initialize_workflow('gisDiscoveryWF')
  end
end
