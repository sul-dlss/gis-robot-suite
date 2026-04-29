# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class GenerateStructural < Base
        def initialize
          super('gisAssemblyWF', 'generate-structural')
        end

        def perform_work
          logger.debug "generate-structural working on #{bare_druid}"

          updated = cocina_object.new(structural: cocina_object.structural.new(contains: contains_params))
          object_client.update(params: updated)
        end

        private

        delegate :version, to: :cocina_object

        def contains_params
          [
            {
              type: 'https://cocina.sul.stanford.edu/models/resources/object',
              externalIdentifier: "#{bare_druid}_1",
              label: 'Data',
              version:,
              structural: {
                contains: GisRobotSuite::DataFileBuilder.build(content_dir:, version:, file_access:)
              }
            },
            {
              type: 'https://cocina.sul.stanford.edu/models/resources/preview',
              externalIdentifier: "#{bare_druid}_2",
              label: 'Preview',
              version:,
              structural: {
                contains: GisRobotSuite::PreviewFileBuilder.build(content_dir:, version:, file_access:)
              }
            },
            {
              type: 'https://cocina.sul.stanford.edu/models/resources/object',
              externalIdentifier: "#{bare_druid}_3",
              label: 'Metadata',
              version:,
              structural: {
                contains: GisRobotSuite::MetadataFileBuilder.build(content_dir:, version:, file_access:)
              }
            }
          ]
        end

        def content_dir
          @content_dir ||= File.join(GisRobotSuite.locate_druid_path(bare_druid, type: :stage), 'content')
        end

        def file_access
          @file_access ||= cocina_object.access.to_h
                                        .slice(:view, :download, :location, :controlledDigitalLending)
                                        .tap do |access|
            access[:view] = 'dark' if access[:view] == 'citation-only'
          end
        end
      end
    end
  end
end
