#!/usr/bin/env ruby
require 'json'

SKIP_LAYERS = %w(
  sde-columbia-sudanadmn4
)

docs = JSON.parse(File.read('geoblacklight.json'))
docs = [docs] unless docs.is_a? Array
docs.delete_if do |doc|
  doc.nil? || SKIP_LAYERS.include?(doc['layer_slug_s']) || doc['dct_provenance_s'] == ''
end

puts "Saving to geoblacklight.json"
File.open('geoblacklight.json', 'w') {|f| f << JSON.pretty_generate(docs)}
