# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class ExtractIso19139 < Base
        def initialize
          super('gisAssemblyWF', 'extract-iso19139')
        end

        def perform_work
          logger.debug "extract-iso19139 working on #{bare_druid}"

          rootdir = GisRobotSuite.locate_druid_path(bare_druid, type: :stage)

          # See if generation is needed
          geo_metadata_filename = File.join(rootdir, 'metadata', 'geoMetadata.xml')
          if File.size?(geo_metadata_filename)
            logger.info "extract-iso19139: #{bare_druid} found #{geo_metadata_filename}"
            return
          end

          begin
            esri_filename = GisRobotSuite.locate_esri_metadata("#{rootdir}/temp")
            if esri_filename =~ /^(.*).(shp|tif).xml$/ || esri_filename =~ %r{^(.*/metadata).xml$}
              output_file = "#{Regexp.last_match(1)}-iso19139.xml"
              ofn_fc = "#{Regexp.last_match(1)}-iso19110.xml"
              ofn_fgdc = "#{Regexp.last_match(1)}-fgdc.xml"
            end
            logger.debug "extract-iso19139 working on #{esri_filename}"
            arcgis_to_iso19139(esri_filename, output_file, ofn_fc, ofn_fgdc)
          rescue RuntimeError => e
            logger.error "extract-iso19139: #{bare_druid} is missing ESRI metadata files"
            raise e
          end
        end

        private

        # XSLT file locations
        XSLT = {
          arcgis: 'config/ArcGIS/Transforms/ArcGIS2ISO19139.xsl',
          arcgis_fc: 'lib/xslt/arcgis_to_iso19110.xsl',
          arcgis_fgdc: 'config/ArcGIS/Transforms/ArcGIS2FGDC.xsl'
        }.freeze

        # XSLT processor
        XSLTPROC = 'xsltproc --novalid --xinclude'
        # XML cleaner
        XMLLINT = 'xmllint --format --xinclude --nsclean'

        # Converts an ESRI ArcCatalog metadata.xml into ISO 19139
        # @param [String] input_file Input file
        # @param [String] output_file Output file
        # @param [String] ofn_fc Output file for the Feature Catalog (optional)
        def arcgis_to_iso19139(input_file, output_file, ofn_fc = nil, ofn_fgdc = nil)
          logger.info "generating #{output_file}"
          # Root of the project.  This is needed to find the XSLT files.
          basepath = File.absolute_path("#{__FILE__}/../../../../..")
          system("#{XSLTPROC} #{File.join(basepath, XSLT[:arcgis])} '#{input_file}' | #{XMLLINT} -o '#{output_file}' -", exception: true)
          unless ofn_fc.nil?
            logger.info "generating #{ofn_fc}"
            system("#{XSLTPROC} #{File.join(basepath, XSLT[:arcgis_fc])} '#{input_file}' | #{XMLLINT} -o '#{ofn_fc}' -", exception: true)
          end
          return if ofn_fgdc

          logger.info "generating #{ofn_fgdc}"
          system("#{XSLTPROC} #{File.join(basepath, XSLT[:arcgis_fgdc])} '#{input_file}' | #{XMLLINT} -o '#{ofn_fgdc}' -", exception: true)
        end
      end
    end
  end
end
