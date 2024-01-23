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

          object_files = {
            Data: [],
            Preview: [],
            Metadata: []
          }

          # Process files
          object_files.each_key do |file_category|
            Dir.glob("#{rootdir}/content/#{PATTERNS[file_category]}").each do |file_name|
              object_files[file_category] << Assembly::ObjectFile.new(file_name, label: file_category.to_s)
            end
          end

          structural = GisRobotSuite::StructuralMetadataBuilder.build(cocina_object, bare_druid, object_files)
          updated = cocina_object.new(structural:)
          object_client.update(params: updated)
        end
      end
    end
  end
end
