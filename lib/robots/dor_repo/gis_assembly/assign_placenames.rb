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
          object_client.update(params: cocina_object.new(description: description_props))
        end

        private

        def description_props
          @description_props ||= cocina_object.description.to_h
        end

        def gazetteer
          @gazetteer ||= GisRobotSuite::Gazetteer.new
        end

        def resolve_placenames
          place_subjects.each do |subject|
            value = subject[:value]
            uri = gazetteer.find_placename_uri(value)
            if uri.nil?
              logger.warn "assign-placenames: #{bare_druid} is missing gazetteer entry for '#{value}'" unless gazetteer.blank?(value)
              next
            end
            add_uri_to_subject(subject, uri)
            add_uri_to_coverage(value, uri)
          end
        end

        def place_subjects
          description_props[:subject].select { |subject| subject[:type] == 'place' }
        end

        def add_uri_to_subject(subject, uri)
          subject[:uri] = uri
          subject[:source] = {
            code: 'geonames',
            uri: 'http://www.geonames.org/ontology#'
          }
        end

        def coverage_subjects_for(value)
          description_props[:geographic].flat_map do |geographic|
            geographic[:subject].select { |subject| subject[:value] == value && subject[:type] == 'coverage' }
          end
        end

        def add_uri_to_coverage(value, uri)
          coverage_subjects_for(value).each do |subject|
            subject[:uri] = uri
          end
        end
      end
    end
  end
end
