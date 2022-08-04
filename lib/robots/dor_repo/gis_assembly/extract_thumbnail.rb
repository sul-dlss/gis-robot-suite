# frozen_string_literal: true

require 'base64'

module Robots
  module DorRepo
    module GisAssembly
      class ExtractThumbnail < Base
        def initialize
          super('gisAssemblyWF', 'extract-thumbnail', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid = druid.delete_prefix('druid:')
          LyberCore::Log.debug "extract-thumbnail working on #{druid}"
          extract_thumbnail druid
        end

        # Extracts an inline thumbnail from the ESRI ArcCatalog metadata format
        # @raise [ArgumentError] if cannot find a thumbnail
        def extract_thumbnail(druid)
          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage

          # ensure content folder is present
          content_dir = File.join(rootdir, 'content')
          FileUtils.mkdir(content_dir) unless File.directory?(content_dir)

          # see if we have work to do
          thumbnail_file = File.join(content_dir, 'preview.jpg')
          if File.size?(thumbnail_file)
            LyberCore::Log.info "extract-thumbnail: #{druid} found existing thumbnail: #{thumbnail_file}"
            return
          end

          # @param [String] esri_metadata_file the metadata
          esri_metadata_file = GisRobotSuite.locate_esri_metadata "#{rootdir}/temp"
          raise "extract-thumbnail: #{druid} is missing ESRI metadata files" if esri_metadata_file.nil?

          # parse ESRI XML and extract base64 encoded thumbnail image
          doc = Nokogiri::XML(File.read(esri_metadata_file))
          doc.xpath('//Binary/Thumbnail/Data').each do |node|
            if node['EsriPropertyType'] == 'PictureX'
              image = Base64.decode64(node.text)
              File.open(thumbnail_file, 'wb') { |f| f << image }
              raise "extract-thumbnail: #{druid} cannot create #{thumbnail_file}" unless File.size?(thumbnail_file)

              # rubocop:disable Lint/NonLocalExitFromIterator
              return
              # rubocop:enable Lint/NonLocalExitFromIterator
            else
              LyberCore::Log.warn "extract-thumbnail: #{druid} has unknown EsriPropertyType: #{node['EsriPropertyType']}"
            end
          end
          raise "extract-thumbnail: #{druid} is missing thumbnail in ESRI metadata file: #{esri_metadata_file}"
        end
      end
    end
  end
end
