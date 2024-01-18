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

          resolve_placenames

          description_props = Cocina::Models::Mapping::FromMods::Description.props(mods: mods_doc, druid:,
                                                                                   label: cocina_object.label)
          object_client.update(params: cocina_object.new(description: description_props))
        end

        private

        def mods_doc
          @mods_doc ||= Cocina::Models::Mapping::ToMods::Description.transform(cocina_object.description, druid)
        end

        def gazetteer
          @gazetteer ||= GisRobotSuite::Gazetteer.new
        end

        def geographic_nodes
          mods_doc.xpath('//mods:geographic', 'mods' => 'http://www.loc.gov/mods/v3')
        end

        def coverage_nodes
          mods_doc.xpath('//mods:extension//dc:coverage', 'mods' => 'http://www.loc.gov/mods/v3', 'dc' => 'http://purl.org/dc/elements/1.1/')
        end

        #
        # Resolves placenames using local gazetteer
        #
        #   * Changes subject/geographic with GeoNames as authority to have the correct valueURI
        #   * Adds correct rdf:resource to geo extension
        #   * Adds a LCSH or LCNAF keyword if needed
        #
        def resolve_placenames
          geographic_nodes.each do |node|
            content = node.content

            # Verify Gazetteer keyword
            uri = gazetteer.find_placename_uri(content)
            if uri.nil?
              logger.warn "assign-placenames: #{bare_druid} is missing gazetteer entry for '#{content}'" unless gazetteer.blank?(content)
              next
            end

            # Ensure correct valueURI for subject/geographic for GeoNames
            node['valueURI'] = uri
            node['authority'] = 'geonames'
            node['authorityURI'] = 'http://www.geonames.org/ontology#'

            # Correct any linkages for placenames in the geo extension
            coverage_nodes.each do |coverage_node|
              if coverage_node['dc:title'] == content
                logger.debug "assign-placenames: #{bare_druid} correcting dc:coverage@rdf:resource for #{content}"
                coverage_node['rdf:resource'] = uri
              end
            end

            # Add a LC heading if needed
            lc = gazetteer.find_loc_keyword(content)
            next if lc.nil? || content == lc

            logger.debug "assign-placenames: #{bare_druid} adding Library of Congress entry to end of MODS record"
            lc_auth = gazetteer.find_loc_authority(content)
            next if lc_auth.nil?

            lc_uri = gazetteer.find_loc_authority(content)
            lc_uri = " valueURI='#{lc_uri}'" unless lc_uri.nil?
            node.parent.parent << Nokogiri::XML("
                  <subject>
                    <geographic authority='#{lc_auth}'#{lc_uri}>#{lc}</geographic>
                  </subject>
                  ").root
          end
        end
      end
    end
  end
end
