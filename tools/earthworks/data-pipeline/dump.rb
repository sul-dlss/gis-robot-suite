#!/usr/bin/env ruby

require 'rsolr'
require 'json'

#solr = RSolr.connect url: 'http://localhost:8983/solr/kurma-earthworks-v1-dev'
solr = RSolr.connect url: 'https://sul-solr.stanford.edu/solr/kurma-earthworks-prod'
puts solr.inspect

n = 1
while true do
  response = solr.paginate n, 1000, 'select', :params => {:q => '*:*'}
  docs = response['response']['docs']
  break if docs.length == 0
  puts "Writing page #{n}"
  docs.map! do |doc|
    %w(score timestamp _version_).each {|k| doc.delete(k) if doc.include?(k) }
    doc
  end
  File.open('data/dump%03d.json' % n, 'w') {|f| f << JSON.pretty_generate(docs) }
  n += 1
end
