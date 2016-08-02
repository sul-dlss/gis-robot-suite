#!/usr/bin/env ruby
require 'json'

docs = []
ARGV.each do |dir|
  Dir.glob("#{dir}/**/{filtered,geoblacklight}*.json") do |fn|
    puts "Loading #{fn}"
    data = JSON.parse(File.read(fn))
    data = [data] unless data.is_a? Array
    data.each do |doc|
      docs << doc unless doc.nil?
    end
  end
end

puts "Saving to geoblacklight.json"
File.open("geoblacklight.json", 'w') {|f| f << JSON.pretty_generate(docs)}
