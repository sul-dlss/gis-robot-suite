# frozen_string_literal: true

require 'fastimage'
require 'mime/types'
require 'assembly-objectfile'

# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisAssembly   # This is your workflow package name (using CamelCase)
      class GenerateContentMetadata < Base
        def initialize
          super('gisAssemblyWF', 'generate-content-metadata', check_queued_status: true) # init LyberCore::Robot
        end

        FILE_ATTRIBUTES = Assembly::ContentMetadata::File::ATTRIBUTES_FOR_TYPE.merge(
          'image/png' => Assembly::ContentMetadata::File::ATTRIBUTES_FOR_TYPE['image/jp2'] # preview image
        )

        # @param [String] druid
        # @param [Hash<Symbol,Assembly::ObjectFile>] objects
        # @param [Nokogiri::XML::DocumentFragment] geoData
        # @param [Hash] flags
        # @return [Nokogiri::XML::Document]
        # @see [Assembly::ContentMetadata]
        # @see https://consul.stanford.edu/display/chimera/Content+metadata+--+the+contentMetadata+datastream
        def create_content_metadata(druid, objects, geoData, flags = {})
          Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
            xml.contentMetadata(objectId: "#{druid}", type: flags[:content_type] || 'geo') do
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
                  id: "#{druid}_#{seq}",
                  sequence: seq,
                  type: resource_type
                ) do
                  xml.label k.to_s
                  v.each do |o|
                    fail ArgumentError unless o.is_a? Assembly::ObjectFile

                    mimetype = o.image? ? MIME::Types.type_for("xxx.#{FastImage.type(o.path)}").first.to_s : o.mimetype
                    o.file_attributes ||= FILE_ATTRIBUTES[mimetype] || FILE_ATTRIBUTES['default']
                    [:publish, :shelve].each { |t| o.file_attributes[t] = 'yes' }

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

                    case roletype
                    when 'master'
                      o.file_attributes[:preserve] = 'yes'
                    else
                      o.file_attributes[:preserve] = 'no'
                    end

                    xml.file o.file_attributes.merge(
                      id: o.filename,
                      mimetype: mimetype,
                      size: o.filesize,
                      role: roletype || 'master') do
                      if resource_type == :object
                        if roletype == 'master' && !geoData.nil?
                          xml.geoData do
                            xml.parent.add_child geoData
                          end
                          geoData = nil # only once
                        else
                          if o.filename =~ /_EPSG_(\d+)\.zip/i
                            xml.geoData srsName: "EPSG:#{Regexp.last_match(1)}"
                          end
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
        }

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid = druid.delete_prefix('druid:')
          LyberCore::Log.debug "generate-content-metadata working on #{druid}"

          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage

          objects = {
            Data: [],
            Preview: [],
            Metadata: []
          }

          # Process files
          objects.each_key do |k|
            Dir.glob(rootdir + '/content/' + PATTERNS[k]).each do |fn|
              objects[k] << Assembly::ObjectFile.new(fn, label: k.to_s)
            end
          end

          # extract the MODS extension cleanly
          modsfn = "#{rootdir}/metadata/descMetadata.xml"
          fail "generate-content-metadata: #{druid} is missing MODS metadata" unless File.size?(modsfn)

          doc = Nokogiri::XML(File.read(modsfn))
          ns = {
            'rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
            'mods' => 'http://www.loc.gov/mods/v3'
          }
          geoData = doc.dup.xpath('/mods:mods/mods:extension[@displayLabel="geo"]/rdf:RDF/rdf:Description', ns).first

          xml = create_content_metadata druid, objects, geoData
          fn = "#{rootdir}/metadata/contentMetadata.xml"
          File.open(fn, 'wb') do |f|
            f.write(xml)
          end
          fail "generate-content-metadata: #{druid} cannot create contentMetadata: #{fn}" unless File.size?(fn)
        end
      end
    end
  end
end
