# frozen_string_literal: true

require 'fastimage'
require 'mime/types'
require 'assembly-objectfile'

module Robots
  module DorRepo
    module GisAssembly
      class GenerateContentMetadata < Base
        def initialize
          super('gisAssemblyWF', 'generate-content-metadata')
        end

        def perform_work
          logger.debug "generate-content-metadata working on #{bare_druid}"

          rootdir = GisRobotSuite.locate_druid_path bare_druid, type: :stage

          objects = {
            Data: [],
            Preview: [],
            Metadata: []
          }

          # Process files
          objects.each_key do |k|
            Dir.glob("#{rootdir}/content/#{PATTERNS[k]}").each do |fn|
              objects[k] << Assembly::ObjectFile.new(fn, label: k.to_s)
            end
          end

          # extract the MODS extension cleanly
          modsfn = "#{rootdir}/metadata/descMetadata.xml"
          raise "generate-content-metadata: #{bare_druid} is missing MODS metadata" unless File.size?(modsfn)

          doc = Nokogiri::XML(File.read(modsfn))
          ns = {
            'rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
            'mods' => 'http://www.loc.gov/mods/v3'
          }
          geo_data_xml = doc.dup.xpath('/mods:mods/mods:extension[@displayLabel="geo"]/rdf:RDF/rdf:Description', ns).first

          xml = create_content_metadata(objects, geo_data_xml)
          fn = "#{rootdir}/metadata/contentMetadata.xml"
          File.binwrite(fn, xml)
          raise "generate-content-metadata: #{bare_druid} cannot create contentMetadata: #{fn}" unless File.size?(fn)
        end

        private

        # @param [Hash<Symbol,Assembly::ObjectFile>] objects
        # @param [Nokogiri::XML::DocumentFragment] geo_data_xml
        # @return [Nokogiri::XML::Document]
        # @see https://consul.stanford.edu/display/chimera/Content+metadata+--+the+contentMetadata+datastream
        def create_content_metadata(objects, geo_data_xml)
          Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
            xml.contentMetadata(objectId: bare_druid, type: 'geo') do
              seq = 1
              objects.each do |k, v|
                next if v.nil? || v.empty?

                resource_type = case k
                                when :Data
                                  :object
                                when :Preview
                                  :preview
                                else
                                  :attachment
                                end
                xml.resource(
                  id: "#{bare_druid}_#{seq}",
                  sequence: seq,
                  type: resource_type
                ) do
                  xml.label k.to_s
                  v.each do |o|
                    raise ArgumentError unless o.is_a? Assembly::ObjectFile

                    mimetype = o.image? ? MIME::Types.type_for("xxx.#{FastImage.type(o.path)}").first.to_s : o.mimetype

                    roletype = if mimetype == 'application/zip'
                                 if o.path =~ /_(EPSG_\d+)/i # derivative
                                   'derivative'
                                 else
                                   'master'
                                 end
                               elsif o.image?
                                 if o.path =~ /_small.png$/
                                   'derivative'
                                 else
                                   'master'
                                 end
                               end || nil

                    o.file_attributes ||= {}
                    [:publish, :shelve].each { |t| o.file_attributes[t] = 'yes' }
                    o.file_attributes[:preserve] = if roletype == 'master'
                                                     'yes'
                                                   else
                                                     'no'
                                                   end

                    xml.file o.file_attributes.merge(
                      id: o.filename,
                      mimetype:,
                      size: o.filesize,
                      role: roletype || 'master'
                    ) do
                      if resource_type == :object
                        if roletype == 'master' && !geo_data_xml.nil?
                          xml.geoData do
                            xml.parent.add_child geo_data_xml
                          end
                          geo_data_xml = nil # only once
                        elsif o.filename =~ /_EPSG_(\d+)\.zip/i
                          xml.geoData srsName: "EPSG:#{Regexp.last_match(1)}"
                        end
                      end
                      xml.checksum(o.sha1, type: 'sha1')
                      xml.checksum(o.md5, type: 'md5')
                      if o.image?
                        wh = FastImage.size(o.path)
                        xml.imageData width: wh[0], height: wh[1]
                      end
                    end
                  end
                  seq += 1
                end
              end
            end
          end.doc.to_xml(indent: 2)
        end

        PATTERNS = {
          Data: '*.{zip,TAB,tab,dat,bin,xls,xlsx,tar,tgz,csv,tif,json,geojson,topojson,dbf}',
          Preview: '*.{png,jpg,gif,jp2}',
          Metadata: '*.{xml,txt,pdf}'
        }.freeze
      end
    end
  end
end
