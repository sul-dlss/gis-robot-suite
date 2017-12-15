#!/usr/bin/env ruby
#
# Usage: upload.rb http://localhost:8080/my-collection file1.xml [file2.json...]
#
require 'rsolr'
require 'nokogiri'
require 'benchmark'

if ARGV.size < 2
  puts 'Usage: upload.rb http://localhost:8080/my-collection file1.xml [file2.json...]'
  exit(-1)
end

stop_on_error = false

solr = RSolr.connect(url: ARGV.delete_at(0))
puts solr.inspect

ARGV.each do |fn|
  puts "Processing #{fn}"
  begin
    if fn =~ /.xml$/
      doc = Nokogiri::XML(File.open(fn, 'rb').read)
      solr.update(data: doc.to_xml)
    elsif fn =~ /.json$/
      doc = JSON.parse(File.open(fn, 'rb').read)
      n = 1000
      i = 1
      [doc].flatten.each_slice(n) do |docs|
        begin
          puts "add #{docs.length} documents: " + Benchmark.measure { solr.add docs }.to_s
          puts 'commit:' + Benchmark.measure { solr.commit }.to_s
          puts "Processed #{n*i} records"
          i = i + 1
        rescue => e
          puts 'ERROR: ' + e.inspect[0..8192]
          raise e if stop_on_error
        end
      end
    else
      raise "Unknown file type: #{fn}"
    end
  rescue => e
    puts "ERROR: #{e}: #{e.backtrace}"
    raise e if stop_on_error
  end
end

solr.commit
