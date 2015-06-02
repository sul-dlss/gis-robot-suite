#!/usr/bin/env ruby
#
# Usage: generate_sitemap.rb http://localhost:8080/solr/my-collection http://example.com
#

require 'rsolr'
require 'sitemap_generator'

# fetch all the slugs
solr = RSolr.connect url: ARGV[0]
slugs = []
response = solr.get 'select', params: {
  q: '*:*',
  rows: 100_000,
  fl: 'layer_slug_s'
}
response['response']['docs'].each do |doc|
  slugs << doc['layer_slug_s']
end

# generate sitemap.xml.gz
SitemapGenerator::Sitemap.default_host = ARGV[1]
SitemapGenerator::Sitemap.create do
  slugs.sort.each do |slug|
    add "/catalog/#{slug}"
  end
end
