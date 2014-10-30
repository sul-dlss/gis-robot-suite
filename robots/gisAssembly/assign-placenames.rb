$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "schema", "lib"))
require 'geoblacklight/gazetteer'

# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisAssembly   # This is your workflow package name (using CamelCase)

      class AssignPlacenames # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 

        def initialize
          super('dor', 'gisAssemblyWF', 'assign-placenames', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "assign-placenames working on #{druid}"
          
          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage          
          modsFn = File.join(rootdir, 'metadata', 'descMetadata.xml')
          raise RuntimeError, "assign-placenames: #{druid} is missing MODS metadata" unless File.exists?(modsFn)
          
          resolve_placenames(druid, modsFn)
        end
        
        #
        # Resolves placenames using local gazetteer
        #
        #   * Changes subject/geographic with GeoNames as authority to have the correct valueURI
        #   * Adds correct rdf:resource to geo extension
        #   * Adds a LCSH or LCNAF keyword if needed
        #
        def resolve_placenames(druid, modsFn)
          LyberCore::Log.debug "assign-placenames: #{druid} is processing #{modsFn}"
          g = GeoBlacklightSchema::Gazetteer.new
          mods = Nokogiri::XML(File.open(modsFn, 'rb'))
          r = mods.xpath('//mods:geographic', { 'mods' => 'http://www.loc.gov/mods/v3' })
          r.each do |i|
            k = i.content 
    
            # Verify Gazetteer keyword
            uri = g.find_placename_uri(k)
            if uri.nil?
              LyberCore::Log.warn "assign-placenames: #{druid} is missing gazetteer entry for '#{k}'"
              next
            end

            # Ensure correct valueURI for subject/geographic for GeoNames
            i['valueURI'] = uri
            i['authority'] = 'geonames'
            i['authorityURI'] = 'http://www.geonames.org/ontology#'

            # Correct any linkages for placenames in the geo extension
            coverages = mods.xpath('//mods:extension//dc:coverage', { 'mods' => 'http://www.loc.gov/mods/v3', 'dc' => 'http://purl.org/dc/elements/1.1/' })
            coverages.each do |j|
              if j['dc:title'] == k
                LyberCore::Log.debug "assign-placenames: #{druid} correcting dc:coverage@rdf:resource for #{k}"
                j['rdf:resource'] = uri + 'about.rdf'
              end
            end
    
            # Add a LC heading if needed
            lc = g.find_loc_keyword(k)
            unless lc.nil? or k == lc
              LyberCore::Log.debug "assign-placenames: #{druid} adding Library of Congress entry to end of MODS record"
              lcauth = g.find_loc_authority(k)
              unless lcauth.nil?
                lcuri = g.find_loc_authority(k)
                unless lcuri.nil?
                  lcuri = " valueURI='#{lcuri}'"
                end
                i.parent.parent << Nokogiri::XML("
        <subject>
          <geographic authority='#{lcauth}'#{lcuri}>#{lc}</geographic>
        </subject>
        ").root
              end
            end
          end
  
          # Save XML tree
          mods.write_to(File.open(modsFn, 'wb'), :encoding => 'UTF-8', :indent => 2)
        end
      end
    end
  end
end
