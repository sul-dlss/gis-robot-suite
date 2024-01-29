# frozen_string_literal: true

require 'fastimage'
require 'assembly-objectfile'

module Robots
  module DorRepo
    module GisAssembly
      class GenerateContentMetadata < Base
        def initialize
          super('gisAssemblyWF', 'generate-content-metadata')
        end

        def perform_work
          logger.debug "generate-content-metadata working on #{bare_druid}"

          updated = cocina_object.new(structural: cocina_object.structural.new(contains: contains_params))
          object_client.update(params: updated)
        end

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
            }
          ]
        end

        def rootdir
          @rootdir ||= GisRobotSuite.locate_druid_path(bare_druid, type: :stage)
        end

        def data_zip_objectfile
          @data_zip_objectfile ||= Assembly::ObjectFile.new(GisRobotSuite.data_zip_filepath(rootdir, bare_druid))
        end

        def epsg_data_zip_objectfile
          @epsg_data_zip_objectfile ||= Assembly::ObjectFile.new(GisRobotSuite.normalized_data_zip_filepath(rootdir, bare_druid))
        end

        def preview_objectfile
          @preview_objectfile ||= Assembly::ObjectFile.new("#{rootdir}/content/preview.jpg")
        end

        def index_map_objectfile
          @index_map_objectfile ||= Assembly::ObjectFile.new("#{rootdir}/content/index_map.json")
        end

        def preview_presentation_params
          wh = FastImage.size(preview_objectfile.path)
          { width: wh[0], height: wh[1] }
        end

        def file_access_params
          @file_access_params ||= cocina_object.access.to_h
                                               .slice(:view, :download, :location, :controlledDigitalLending)
                                               .tap do |access|
            access[:view] = 'dark' if access[:view] == 'citation-only'
          end
        end

        def data_files_params
          [
            {
              type: 'https://cocina.sul.stanford.edu/models/file',
              externalIdentifier: "https://cocina.sul.stanford.edu/file/#{SecureRandom.uuid}",
              label: "#{bare_druid}.zip",
              filename: "#{bare_druid}.zip",
              size: data_zip_objectfile.filesize,
              version: cocina_object.version,
              hasMimeType: 'application/zip',
              use: 'master',
              hasMessageDigests: [
                {
                  type: 'sha1',
                  digest: data_zip_objectfile.sha1
                },
                {
                  type: 'md5',
                  digest: data_zip_objectfile.md5
                }
              ],
              access: file_access_params,
              administrative: {
                publish: true,
                sdrPreserve: true,
                shelve: true
              }
            },
            {
              type: 'https://cocina.sul.stanford.edu/models/file',
              externalIdentifier: "https://cocina.sul.stanford.edu/file/#{SecureRandom.uuid}",
              label: "#{bare_druid}_normalized.zip",
              filename: "#{bare_druid}_normalized.zip",
              size: epsg_data_zip_objectfile.filesize,
              version: cocina_object.version,
              hasMimeType: 'application/zip',
              use: 'derivative',
              hasMessageDigests: [
                {
                  type: 'sha1',
                  digest: epsg_data_zip_objectfile.sha1
                },
                {
                  type: 'md5',
                  digest: epsg_data_zip_objectfile.md5
                }
              ],
              access: file_access_params,
              administrative: {
                publish: true,
                sdrPreserve: false,
                shelve: true
              }
            }
          ].tap do |params|
            # Add index_map.json if it exists
            params << index_map_params if index_map_objectfile.file_exists?
          end
        end

        def index_map_params
          {
            type: 'https://cocina.sul.stanford.edu/models/file',
            externalIdentifier: "https://cocina.sul.stanford.edu/file/#{SecureRandom.uuid}",
            label: 'index_map.json',
            filename: 'index_map.json',
            size: index_map_objectfile.filesize,
            version: cocina_object.version,
            hasMimeType: 'application/json',
            use: 'master',
            hasMessageDigests: [
              {
                type: 'sha1',
                digest: index_map_objectfile.sha1
              },
              {
                type: 'md5',
                digest: index_map_objectfile.md5
              }
            ],
            access: file_access_params,
            administrative: {
              publish: true,
              sdrPreserve: true,
              shelve: true
            }
          }
        end

        def preview_file_params
          [
            {
              type: 'https://cocina.sul.stanford.edu/models/file',
              externalIdentifier: "https://cocina.sul.stanford.edu/file/#{SecureRandom.uuid}",
              label: 'preview.jpg',
              filename: 'preview.jpg',
              size: preview_objectfile.filesize,
              version: cocina_object.version,
              hasMimeType: 'image/jpeg',
              use: 'master',
              hasMessageDigests: [
                {
                  type: 'sha1',
                  digest: preview_objectfile.sha1
                },
                {
                  type: 'md5',
                  digest: preview_objectfile.md5
                }
              ],
              access: file_access_params,
              administrative: {
                publish: true,
                sdrPreserve: true,
                shelve: true
              },
              presentation: preview_presentation_params
            }
          ]
        end
      end
    end
  end
end
