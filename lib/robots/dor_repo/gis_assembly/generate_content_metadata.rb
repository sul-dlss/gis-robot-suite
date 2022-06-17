# frozen_string_literal: true

require 'fastimage'
require 'mime/types'
require 'assembly-objectfile'

module Robots
  module DorRepo
    module GisAssembly
      class GenerateContentMetadata < Base
        def initialize
          super('gisAssemblyWF', 'generate-content-metadata')
        end

        PATTERNS = {
          Data: '*.{zip,TAB,tab,dat,bin,xls,xlsx,tar,tgz,csv,tif,json,geojson,topojson,dbf}',
          Preview: '*.{png,jpg,gif,jp2}',
          Metadata: '*.{xml,txt,pdf}'
        }.freeze

        def perform_work
          logger.debug "generate-content-metadata working on #{bare_druid}"

          rootdir = GisRobotSuite.locate_druid_path(bare_druid, type: :stage)

          objects = {
            Data: [],
            Preview: [],
            Metadata: []
          }

          # Process files
          objects.each_key do |k|
            Dir.glob("#{rootdir}/content/#{PATTERNS[k]}").each do |fn|
              objects[k] << Assembly::ObjectFile.new(fn, label: k.to_s)
            end
          end

          object_client = Dor::Services::Client.object("druid:#{bare_druid}")
          cocina_model = object_client.find
          structural = GisRobotSuite::StructuralMetadataBuilder.build(cocina_model, bare_druid, objects)
          updated = cocina_model.new(structural:)
          object_client.update(params: updated)
        end
      end
    end
  end
end
