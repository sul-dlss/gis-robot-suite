#!/usr/bin/env ruby
require 'dor-services'

# For the georeferenced map, here: http://purl.stanford.edu/yn681zp0153
# A relatedItem entry in the MODS should be generated as follows:
#
# <relatedItem type="otherFormat" displayLabel="Georeferenced Map">
#    <titleInfo>
#      <title>Map of South Africa (Raster Image)</title>
#    </titleInfo>
#    <location>
#     <url>http://purl.stanford.edu/nz926xc1513</url>
#    </location>
# </relatedItem>
#
def add_link_to_mods(item, to_druid, to_title, display_label, type = 'otherFormat')
  doc = Nokogiri::XML(item.datastreams['descMetadata'].content)

  relatedItem = doc.create_element 'relatedItem'
  relatedItem['type'] = type
  relatedItem['displayLabel'] = display_label

  titleInfo = doc.create_element 'titleInfo'
  title = doc.create_element 'title', to_title
  titleInfo << title

  location = doc.create_element 'location'
  url = doc.create_element 'url', "http://purl.stanford.edu/#{to_druid}"
  location << url

  relatedItem << titleInfo
  relatedItem << location
  doc.root << relatedItem

  item.datastreams['descMetadata'].content = doc.to_xml
end

def create_link(from_druid, to_druid, to_title, to_label, versioning = true)
  puts "creating link from #{from_druid} to #{to_druid} for #{to_label}..."

  item = Dor::Item.find("druid:#{from_druid}")
  item.open_new_version if versioning
  add_link_to_mods(item, to_druid, to_title, to_label)
  item.save
  item.close_version(description: "creating MODS link to #{to_druid}") if versioning
end

# MAIN
require_relative 'config/boot'

druid_mapping = {}
druid_title = {}
CSV.foreach('druid_mapping.csv', :headers => true) do |row|
  druid_mapping[row['scanned_map'].to_s.strip] = row['georeferenced_map'].to_s.strip
  druid_title[row['georeferenced_map'].to_s.strip] = row['georeferenced_title'].to_s.strip
end
fail unless druid_mapping.size == druid_title.size

druid_mapping.each_pair do |scanned, georeferenced|
  create_link(scanned, georeferenced, druid_title[georeferenced], 'Georeferenced Map')
  # create_link(georeferenced, scanned, Dor::Item.find("druid:#{scanned}").label, 'Scanned Map')
end
