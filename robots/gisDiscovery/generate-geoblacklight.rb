require 'date' # for rfc3339
require 'geo_combine'

# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisDiscovery   # This is your workflow package name (using CamelCase)
      class GenerateGeoblacklight # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot

        XSLFN = File.expand_path(File.dirname(__FILE__) + '../../../lib/xslt/mods2geoblacklight.xsl')

        def initialize
          super('dor', 'gisDiscoveryWF', 'generate-geoblacklight', check_queued_status: true) # init LyberCore::Robot
          fail 'generate-geoblacklight: mods2geoblacklight.xsl is not installed' unless File.size?(XSLFN) # locate XSLT
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid = GisRobotSuite.initialize_robot druid
          LyberCore::Log.debug "generate-geoblacklight: #{druid} working"

          # Always overwrite any existing schema data because either MODS or the Rights may change.
          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage
          ifn = File.join(rootdir, 'metadata', 'descMetadata.xml')

          # load MODS from DOR if not on file system
          retrieve_mods(ifn, druid) unless File.size?(ifn)

          # Generate GeoBlacklight Solr document from descMetadataDS
          ofn = path_to_geoblacklight(rootdir)
          convert_mods2geoblacklight druid, ifn, ofn, *determine_rights(druid)

          # Enhance the metadata using GeoCombine
          enhance_geoblacklight ofn, druid, rootdir
        end

        protected

        def enhance_geoblacklight(ifn, druid, rootdir)
          ofn = ifn.gsub(/\.xml$/, '.json')

          # convert XML into JSON
          doc = Nokogiri::XML(File.read(ifn))
          h = {}
          doc.xpath('//xmlns:field').each do |node|
            # for each field copy into hash, but if multiple values, copy into array
            k = node['name'].to_s
            v = node.content.to_s
            v = v.to_i if k =~ /_(i|l)$/ # integer
            v = v.to_f if k =~ /_(d|f)$/ # decimal
            if h[k].nil?
              h[k] = v # assign singleton
              h[k] = [v].flatten if k =~ /_sm$/ # unless multivalued field
            else
              unless h[k].is_a? Array
                h[k] = [h[k]] # convert singleton into Array
              end
              h[k] << v # add to array
            end
          end
          File.open(ofn, 'wb') { |f| f << JSON.pretty_generate(h) }

          # Finally, do the enhancement
          layer = GeoCombine::Geoblacklight.new(File.read(ofn))
          layer.enhance_metadata
          add_index_maps(layer, druid, rootdir)
          File.open(ofn, 'wb') { |f| f << JSON.pretty_generate(layer.metadata) }
        end

        def convert_mods2geoblacklight(druid, ifn, ofn, rights, rightsMetadata)
          flags = {
            geoserver: (rights == 'Public') ? # case-sensitive
                Dor::Config.geohydra.geoserver.url_public :
                Dor::Config.geohydra.geoserver.url_restricted,
            stacks: Dor::Config.stacks.url
          }

          # run XSLT using xsltproc since Nokogiri doesn't support XPath2
          LyberCore::Log.debug "generate-geoblacklight: #{druid} generating GeoBlacklight metadata in #{ofn}"
          cmd = ['xsltproc',
                 "--stringparam geoserver_root '#{flags[:geoserver]}'",
                 "--stringparam wxs_geoserver_root '#{flags[:geoserver]}'",
                 "--stringparam stacks_root '#{flags[:stacks]}'",
                 "--stringparam now '#{Time.now.utc.strftime('%FT%TZ')}'",
                 "--stringparam rights '#{rights}'",
                 "--stringparam rights_metadata '#{rightsMetadata}'",
                 "--output '#{ofn}'",
                 "'#{XSLFN}'",
                 "'#{ifn}'"
                ].join(' ')
          system cmd
          fail "generate-geoblacklight: #{druid} cannot transform MODS into GeoBlacklight schema" unless File.size?(ofn)
        end

        # load MODS from DOR
        def retrieve_mods(fn, druid)
          FileUtils.mkdir_p File.dirname(fn)
          File.open(fn, 'w') { |f| f << Dor::Item.find("druid:#{druid}").descMetadata.ng_xml.to_xml }
        end

        # looks in DOR for rights information, defaults to Restricted
        #
        # @return [Array<String>] the rights and the full rightsMetadata
        def determine_rights(druid)
          rights = 'Restricted'
          xml = Dor::Item.find("druid:#{druid}").rightsMetadata.ng_xml
          if xml.search('//rightsMetadata/access[@type=\'read\']/machine/world').length > 0
            rights = 'Public'
          end

          [rights, xml.to_xml(indent: 0)]
        end

        # @return [String] fn for geoblacklight.xml and ensures that fn doesn't exist
        def path_to_geoblacklight(rootdir)
          File.join(rootdir, 'metadata', 'geoblacklight.xml').tap do |fn|
            if File.size?(fn)
              LyberCore::Log.debug "generate-geoblacklight: regenerating GeoBlacklight metadata in #{fn}"
              FileUtils.rm_f(fn)
            end
          end
        end

        # adds an OpenIndexMaps pointer to stacks if we're dealing with an index map, which
        # we determine as having an index_map.json file in its content
        def add_index_maps(layer, druid, rootdir)
          doc = Nokogiri::XML(File.read(File.join(rootdir, 'metadata', 'contentMetadata.xml')))
          return unless doc.search('//file[@id=\'index_map.json\']').length > 0

          refs = JSON.parse(layer.metadata['dct_references_s'])
          refs['https://openindexmaps.org'] = "#{Dor::Config.stacks.url}/file/druid:#{druid}/index_map.json"
          layer.metadata['dct_references_s'] = refs.to_json
        end
      end
    end
  end
end
