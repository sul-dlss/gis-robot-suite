# frozen_string_literal: true

require 'base64'

module Robots
  module DorRepo
    module GisAssembly
      class ExtractThumbnail < Base
        def initialize
          super('gisAssemblyWF', 'extract-thumbnail')
        end

        def perform_work
          logger.debug "extract-thumbnail working on #{bare_druid}"
          extract_thumbnail
        end

        # Extracts an inline thumbnail from the ESRI ArcCatalog metadata format
        # @raise [ArgumentError] if cannot find a thumbnail
        def extract_thumbnail
          rootdir = GisRobotSuite.locate_druid_path bare_druid, type: :stage

          # ensure content folder is present
          content_dir = File.join(rootdir, 'content')
          FileUtils.mkdir(content_dir) unless File.directory?(content_dir)

          # see if we have work to do
          thumbnail_file = File.join(content_dir, 'preview.jpg')
          if File.size?(thumbnail_file)
            logger.info "extract-thumbnail: #{bare_druid} found existing thumbnail: #{thumbnail_file}"
            return
          end

          # @param [String] esri_metadata_file the metadata
          esri_metadata_file = GisRobotSuite.locate_esri_metadata "#{rootdir}/temp"
          raise "extract-thumbnail: #{bare_druid} is missing ESRI metadata files" if esri_metadata_file.nil?

          # parse ESRI XML and extract base64 encoded thumbnail image
          doc = Nokogiri::XML(File.read(esri_metadata_file))
          doc.xpath('//Binary/Thumbnail/Data').each do |node|
            if node['EsriPropertyType'] == 'PictureX'
              image = Base64.decode64(node.text)
              File.open(thumbnail_file, 'wb') { |f| f << image }
              raise "extract-thumbnail: #{bare_druid} cannot create #{thumbnail_file}" unless File.size?(thumbnail_file)

              # rubocop:disable Lint/NonLocalExitFromIterator
              return
              # rubocop:enable Lint/NonLocalExitFromIterator
            else
              logger.warn "extract-thumbnail: #{bare_druid} has unknown EsriPropertyType: #{node['EsriPropertyType']}"
            end
          end
          raise "extract-thumbnail: #{bare_druid} is missing thumbnail in ESRI metadata file: #{esri_metadata_file}"
        end
      end
    end
  end
end
