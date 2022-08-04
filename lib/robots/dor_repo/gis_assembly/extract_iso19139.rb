# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class ExtractIso19139 < Base
        def initialize
          super('gisAssemblyWF', 'extract-iso19139', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid = druid.delete_prefix('druid:')
          LyberCore::Log.debug "extract-iso19139 working on #{druid}"

          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage

          # See if generation is needed
          geo_metadata_filename = File.join(rootdir, 'metadata', 'geoMetadata.xml')
          if File.size?(geo_metadata_filename)
            LyberCore::Log.info "extract-iso19139: #{druid} found #{geo_metadata_filename}"
            return
          end

          begin
            esri_filename = GisRobotSuite.locate_esri_metadata "#{rootdir}/temp"
            if esri_filename =~ /^(.*).(shp|tif).xml$/ || esri_filename =~ %r{^(.*/metadata).xml$}
              output_file = "#{Regexp.last_match(1)}-iso19139.xml"
              ofn_fc = "#{Regexp.last_match(1)}-iso19110.xml"
              ofn_fgdc = "#{Regexp.last_match(1)}-fgdc.xml"
            end
            LyberCore::Log.debug "extract-iso19139 working on #{esri_filename}"
            arcgis_to_iso19139(esri_filename, output_file, ofn_fc, ofn_fgdc)
          rescue RuntimeError => e
            LyberCore::Log.error "extract-iso19139: #{druid} is missing ESRI metadata files"
            raise e
          end
        end

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
          LyberCore::Log.debug "generating #{output_file}"
          system("#{XSLTPROC} #{XSLT[:arcgis]} '#{input_file}' | #{XMLLINT} -o '#{output_file}' -") or raise
          unless ofn_fc.nil?
            LyberCore::Log.debug "generating #{ofn_fc}"
            system("#{XSLTPROC} #{XSLT[:arcgis_fc]} '#{input_file}' | #{XMLLINT} -o '#{ofn_fc}' -") or raise
          end
          return if ofn_fgdc

          LyberCore::Log.debug "generating #{ofn_fgdc}"
          system("#{XSLTPROC} #{XSLT[:arcgis_fgdc]} '#{input_file}' | #{XMLLINT} -o '#{ofn_fgdc}' -") or raise
        end
      end
    end
  end
end
