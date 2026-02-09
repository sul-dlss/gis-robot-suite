# frozen_string_literal: true

require 'fastimage'
require 'assembly-objectfile'

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

        DATA_FILE_MIMETYPES =
          [['.shp', 'application/vnd.shp'],
           ['.shx', 'application/vnd.shx'],
           ['.vat.dbf', 'application/octet-stream'],
           ['.dbf', 'application/vnd.dbf'],
           ['.prj', 'text/plain'],
           ['.cpg', 'text/plain'],
           ['.geojson', 'application/geo+json'],
           ['.tif', 'image/tiff'],
           ['.tfw', 'text/plain'],
           ['.xml', 'application/xml']].freeze
        private_constant :DATA_FILE_MIMETYPES

        private

        def contains_params
          [
            {
              type: 'https://cocina.sul.stanford.edu/models/resources/object',
              externalIdentifier: "#{bare_druid}_1",
              label: 'Data',
              version: cocina_object.version,
              structural: {
                contains: data_files_params
              }
            },
            {
              type: 'https://cocina.sul.stanford.edu/models/resources/preview',
              externalIdentifier: "#{bare_druid}_2",
              label: 'Preview',
              version: cocina_object.version,
              structural: {
                contains: preview_file_params
              }
            },
            {
              type: 'https://cocina.sul.stanford.edu/models/resources/object',
              externalIdentifier: "#{bare_druid}_3",
              label: 'Metadata',
              version: cocina_object.version,
              structural: {
                contains: metadata_file_params
              }
            }
          ]
        end

        def rootdir
          @rootdir ||= GisRobotSuite.locate_druid_path(bare_druid, type: :stage)
        end

        def preview_objectfile_path
          @preview_objectfile_path ||= File.join(rootdir, 'content', 'preview.jpg')
        end

        def preview_objectfile
          raise "Missing preview file: #{preview_objectfile_path}" unless File.exist?(preview_objectfile_path)

          @preview_objectfile ||= Assembly::ObjectFile.new(preview_objectfile_path)
        end

        def preview_presentation_params
          wh = FastImage.size(preview_objectfile.path)
          { width: wh[0], height: wh[1] }
        end

        def esri_metadata_objectfile
          esri_metadata_file = GisRobotSuite.locate_esri_metadata("#{rootdir}/content/")
          @esri_metadata_objectfile ||= Assembly::ObjectFile.new(esri_metadata_file)
        end

        def file_access_params
          @file_access_params ||= cocina_object.access.to_h
                                               .slice(:view, :download, :location, :controlledDigitalLending)
                                               .tap do |access|
                                                 access[:view] = 'dark' if access[:view] == 'citation-only'
          end
        end

        def data_files_params
          GisRobotSuite.locate_data_files(content_dir).map do |file|
            file = to_geojson(file) if File.extname(file) == '.json'
            objectfile = Assembly::ObjectFile.new(file)
            build_file_params(objectfile:, mimetype: mimetype_for_data_file(objectfile))
          end
        end

        def to_geojson(file)
          new_file = File.join(content_dir, "#{File.basename(file, '.json')}.geojson")
          File.rename(file, new_file)
          new_file
        end

        def preview_file_params
          [
            build_file_params(objectfile: preview_objectfile, mimetype: 'image/jpeg', presentation: preview_presentation_params)
          ]
        end

        def metadata_file_params
          [
            build_file_params(objectfile: esri_metadata_objectfile, mimetype: 'application/xml')
          ].tap do |params|
            params.concat(metadata_files)
          end
        end

        def content_dir
          @content_dir ||= "#{rootdir}/content"
        end

        def metadata_files
          GisRobotSuite.locate_derivative_metadata_files(content_dir).map do |file|
            objectfile = Assembly::ObjectFile.new(file)
            build_file_params(objectfile:, mimetype: 'application/xml', use: 'derivative', preserve: false)
          end
        end

        def build_file_params(objectfile:, mimetype:, use: 'master', preserve: true, presentation: nil)
          {
            type: 'https://cocina.sul.stanford.edu/models/file',
            externalIdentifier: "https://cocina.sul.stanford.edu/file/#{SecureRandom.uuid}",
            label: objectfile.filename,
            filename: objectfile.filename,
            size: objectfile.filesize,
            version: cocina_object.version,
            hasMimeType: mimetype || objectfile.mimetype,
            use:,
            hasMessageDigests: [
              {
                type: 'sha1',
                digest: objectfile.sha1
              },
              {
                type: 'md5',
                digest: objectfile.md5
              }
            ],
            access: file_access_params,
            administrative: {
              publish: true,
              sdrPreserve: preserve,
              shelve: true
            }
          }.tap do |params|
            params[:presentation] = presentation if presentation
          end
        end

        def mimetype_for_data_file(objectfile)
          DATA_FILE_MIMETYPES.each do |ext, mimetype|
            return mimetype if objectfile.filename.end_with?(ext)
          end

          'application/octet-stream'
        end
      end
    end
  end
end
