#!/usr/bin/env ruby
require 'json'

Dir.glob('geoblacklight.json').each do |fn|
  data = JSON.parse(File.read(fn))
  fail unless data.is_a?(Array) && data.first.is_a?(Hash)
  data.map! do |doc|
    doc['geoblacklight_version'] = '1.0'
    doc['layer_slug_s'].gsub!(/[^[[:alnum:]]]+/, '-') # normalize to alphanum and - only
    %w(uuid georss_polygon_s georss_point_s georss_box_s dc_relation_sm solr_issued_i solr_bbox).each do |k|
      if doc.include?(k)
        puts "Deleting #{k} for #{doc['layer_slug_s']}"
        doc.delete(k)
      end
    end
    doc
  end
  File.open(fn, 'w') {|f| f << JSON.pretty_generate(data) }
end
