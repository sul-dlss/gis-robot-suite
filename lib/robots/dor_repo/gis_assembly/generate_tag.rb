# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class GenerateTag < Base
        def initialize
          super('gisAssemblyWF', 'generate-tag')
        end

        TAG_GIS = 'Dataset : GIS'

        def perform_work
          logger.debug "generate-tag working on #{bare_druid}"

          current_tags = tags_client.list
          return if current_tags.include?(TAG_GIS)

          tags_client.create(tags: [TAG_GIS])
        end

        def tags_client
          object_client.administrative_tags
        end
      end
    end
  end
end
