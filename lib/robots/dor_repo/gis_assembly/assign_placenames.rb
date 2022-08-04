# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class AssignPlacenames < Base
        def initialize
          super('gisAssemblyWF', 'assign-placenames', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid = druid.delete_prefix('druid:')
          LyberCore::Log.debug "assign-placenames working on #{druid}"

          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage
          mods_filename = File.join(rootdir, 'metadata', 'descMetadata.xml')
          raise "assign-placenames: #{druid} is missing MODS metadata" unless File.size?(mods_filename)

          resolve_placenames(druid, mods_filename)
          raise "assign-placenames: #{druid} corrupted MODS metadata" unless File.size?(mods_filename)
        end

        #
        # Resolves placenames using local gazetteer
        #
        #   * Changes subject/geographic with GeoNames as authority to have the correct valueURI
        #   * Adds correct rdf:resource to geo extension
        #   * Adds a LCSH or LCNAF keyword if needed
        #
        def resolve_placenames(druid, mods_filename)
          LyberCore::Log.debug "assign-placenames: #{druid} is processing #{mods_filename}"
          g = GisRobotSuite::Gazetteer.new
          mods = Nokogiri::XML(File.open(mods_filename, 'rb'))
          r = mods.xpath('//mods:geographic', 'mods' => 'http://www.loc.gov/mods/v3')
          r.each do |i|
            k = i.content

            # Verify Gazetteer keyword
            uri = g.find_placename_uri(k)
            if uri.nil?
              LyberCore::Log.warn "assign-placenames: #{druid} is missing gazetteer entry for '#{k}'" unless g.blank?(k)
              next
            end

            # Ensure correct valueURI for subject/geographic for GeoNames
            i['valueURI'] = uri
            i['authority'] = 'geonames'
            i['authorityURI'] = 'http://www.geonames.org/ontology#'

            # Correct any linkages for placenames in the geo extension
            coverages = mods.xpath('//mods:extension//dc:coverage', 'mods' => 'http://www.loc.gov/mods/v3', 'dc' => 'http://purl.org/dc/elements/1.1/')
            coverages.each do |j|
              if j['dc:title'] == k
                LyberCore::Log.debug "assign-placenames: #{druid} correcting dc:coverage@rdf:resource for #{k}"
                j['rdf:resource'] = uri
              end
            end

            # Add a LC heading if needed
            lc = g.find_loc_keyword(k)
            next if lc.nil? || k == lc

            LyberCore::Log.debug "assign-placenames: #{druid} adding Library of Congress entry to end of MODS record"
            lcauth = g.find_loc_authority(k)
            next if lcauth.nil?

            lcuri = g.find_loc_authority(k)
            lcuri = " valueURI='#{lcuri}'" unless lcuri.nil?
            i.parent.parent << Nokogiri::XML("
                  <subject>
                    <geographic authority='#{lcauth}'#{lcuri}>#{lc}</geographic>
                  </subject>
                  ").root
          end

          # Save XML tree
          File.open(mods_filename, 'wb') do |f|
            mods.write_to(f, encoding: 'UTF-8', indent: 2)
          end
        end
      end
    end
  end
end
