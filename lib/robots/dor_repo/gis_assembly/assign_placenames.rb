# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class AssignPlacenames < Base
        def initialize
          super('gisAssemblyWF', 'assign-placenames')
        end

        def perform_work
          logger.debug "assign-placenames working on #{bare_druid}"

          rootdir = GisRobotSuite.locate_druid_path bare_druid, type: :stage
          mods_filename = File.join(rootdir, 'metadata', 'descMetadata.xml')
          raise "assign-placenames: #{bare_druid} is missing MODS metadata" unless File.size?(mods_filename)

          resolve_placenames(mods_filename)
          raise "assign-placenames: #{bare_druid} corrupted MODS metadata" unless File.size?(mods_filename)
        end

        private

        #
        # Resolves placenames using local gazetteer
        #
        #   * Changes subject/geographic with GeoNames as authority to have the correct valueURI
        #   * Adds correct rdf:resource to geo extension
        #   * Adds a LCSH or LCNAF keyword if needed
        #
        def resolve_placenames(mods_filename)
          logger.debug "assign-placenames: #{bare_druid} is processing #{mods_filename}"
          g = GisRobotSuite::Gazetteer.new
          mods = Nokogiri::XML(File.binread(mods_filename))
          r = mods.xpath('//mods:geographic', 'mods' => 'http://www.loc.gov/mods/v3')
          r.each do |i|
            k = i.content

            # Verify Gazetteer keyword
            uri = g.find_placename_uri(k)
            if uri.nil?
              logger.warn "assign-placenames: #{bare_druid} is missing gazetteer entry for '#{k}'" unless g.blank?(k)
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
                logger.debug "assign-placenames: #{bare_druid} correcting dc:coverage@rdf:resource for #{k}"
                j['rdf:resource'] = uri
              end
            end

            # Add a LC heading if needed
            lc = g.find_loc_keyword(k)
            next if lc.nil? || k == lc

            logger.debug "assign-placenames: #{bare_druid} adding Library of Congress entry to end of MODS record"
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
