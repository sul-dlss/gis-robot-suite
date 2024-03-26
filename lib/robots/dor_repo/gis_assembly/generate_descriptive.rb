# frozen_string_literal: true

require 'scanf'

module Robots
  module DorRepo
    module GisAssembly
      class GenerateDescriptive < Base
        def initialize
          super('gisAssemblyWF', 'generate-descriptive')
        end

        def perform_work
          logger.debug "generate-descriptive working on #{bare_druid}"

          description = GisRobotSuite::DescriptiveMetadataBuilder.build(cocina_model: cocina_object, bare_druid:, iso19139_ng:, logger:)
          updated = cocina_object.new(description:)
          object_client.update(params: updated)
        end

        private

        def iso19139_ng
          rootdir = GisRobotSuite.locate_druid_path(bare_druid, type: :stage)
          iso19139_xml_file = Dir.glob("#{rootdir}/content/**/*-iso19139.xml").first
          raise "Missing iso19139.xml in #{rootdir}/content" unless iso19139_xml_file

          Nokogiri::XML(File.read(iso19139_xml_file))
        end
      end
    end
  end
end
