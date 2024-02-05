# frozen_string_literal: true

require 'fastimage'
require 'assembly-objectfile'

module Robots
  module DorRepo
    module GisAssembly
      class GenerateContentMetadata < Base # rubocop:disable Metrics/ClassLength
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

        def data_zip_objectfile
          @data_zip_objectfile ||= Assembly::ObjectFile.new("#{rootdir}/content/data.zip")
        end

        def epsg_data_zip_objectfile
          @epsg_data_zip_objectfile ||= Assembly::ObjectFile.new("#{rootdir}/content/data_EPSG_4326.zip")
        end

        def preview_objectfile_path
          thumbnail_file = File.join(rootdir, 'content', 'preview.jpg')
          return thumbnail_file if File.size?(thumbnail_file)

          temp_thumbnail_file = File.join(rootdir, 'temp', 'preview.jpg')
          raise "generate_content_metadata: #{bare_druid} is missing thumbnail preview.jpg" unless File.size?(temp_thumbnail_file)

          FileUtils.cp(temp_thumbnail_file, thumbnail_file)
          thumbnail_file
        end

        def preview_objectfile
          @preview_objectfile ||= Assembly::ObjectFile.new(preview_objectfile_path)
        end

        def index_map_objectfile
          @index_map_objectfile ||= Assembly::ObjectFile.new("#{rootdir}/content/index_map.json")
        end

        def preview_presentation_params
          wh = FastImage.size(preview_objectfile.path)
          { width: wh[0], height: wh[1] }
        end

        def esri_metadata_objectfile
          esri_metadata_file = GisRobotSuite.locate_esri_metadata("#{rootdir}/content/")
          @esri_metadata_objectfile ||= Assembly::ObjectFile.new(esri_metadata_file)
        end

        def iso19139_objectfile
          iso19139 = Dir.glob("#{rootdir}/content/*-iso19139.xml").first
          @iso19139_objectfile ||= Assembly::ObjectFile.new(iso19139) if iso19139
        end

        def iso19110_objectfile
          iso19110 = Dir.glob("#{rootdir}/content/*-iso19110.xml").first
          @iso19110_objectfile ||= Assembly::ObjectFile.new(iso19110) if iso19110
        end

        def fgdc_objectfile
          fgdc = Dir.glob("#{rootdir}/content/*-fgdc.xml").first
          @fgdc_objectfile ||= Assembly::ObjectFile.new(fgdc) if fgdc
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
              label: 'data.zip',
              filename: 'data.zip',
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
              label: 'data_EPSG_4326.zip',
              filename: 'data_EPSG_4326.zip',
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

        def metadata_file_params
          [
            {
              type: 'https://cocina.sul.stanford.edu/models/file',
              externalIdentifier: "https://cocina.sul.stanford.edu/file/#{SecureRandom.uuid}",
              label: esri_metadata_objectfile.filename,
              filename: esri_metadata_objectfile.filename,
              size: esri_metadata_objectfile.filesize,
              version: cocina_object.version,
              hasMimeType: 'application/xml',
              use: 'master',
              hasMessageDigests: [
                {
                  type: 'sha1',
                  digest: esri_metadata_objectfile.sha1
                },
                {
                  type: 'md5',
                  digest: esri_metadata_objectfile.md5
                }
              ],
              access: file_access_params,
              administrative: {
                publish: true,
                sdrPreserve: true,
                shelve: true
              }
            }
          ].tap do |params|
            params.concat(metadata_files)
          end
        end

        def metadata_files
          [iso19139_objectfile, iso19110_objectfile, fgdc_objectfile].compact.map do |objectfile|
            { type: 'https://cocina.sul.stanford.edu/models/file',
              externalIdentifier: "https://cocina.sul.stanford.edu/file/#{SecureRandom.uuid}",
              label: objectfile.filename,
              filename: objectfile.filename,
              size: objectfile.filesize,
              version: cocina_object.version,
              hasMimeType: 'application/xml',
              use: 'derivative',
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
                sdrPreserve: false,
                shelve: true
              } }
          end
        end
      end
    end
  end
end
