#!/usr/bin/env ruby
require 'json'
KEEP = %w(Berkeley Harvard MassGIS MIT Tufts)

Dir.glob('data/dump???.json') do |fn|
  puts "Filtering #{fn}"
  docs = JSON.parse(File.read(fn))
  docs = docs.map do |doc|
    KEEP.include?(doc['dct_provenance_s']) ? doc : nil
  end.flatten
  File.open(fn.gsub('dump', 'filtered'), 'w') {|f| f << JSON.pretty_generate(docs)}
end
