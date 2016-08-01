#!/usr/bin/env ruby
require 'json'

SKIP = %w(princeton-th83m123j sde-columbia-sudanadmn4)

docs = []
ARGV.each do |dir|
  Dir.glob("#{dir}/**/{filtered,geoblacklight}*.json") do |fn|
    puts "Loading #{fn}"
    data = JSON.parse(File.read(fn))
    data = [data] unless data.is_a? Array
    data.each do |doc|
      next if doc.nil? || SKIP.include?(doc['layer_slug_s']) || doc['dct_provenance_s'] == ''
      docs << doc
    end
  end
end

puts "Saving to geoblacklight.json"
File.open("geoblacklight.json", 'w') {|f| f << JSON.pretty_generate(docs)}
