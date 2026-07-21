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
            placename_props = gazetteer.find_placename(value)
            if placename_props.nil?
              logger.warn "assign-placenames: #{bare_druid} is missing gazetteer entry for '#{value}'" unless gazetteer.blank?(value)
              next
            end

            subject.merge!(placename_props)
          end
        end

        def place_subjects
          description_props[:subject].select { |subject| subject[:type] == 'place' }
        end
      end
    end
  end
end
