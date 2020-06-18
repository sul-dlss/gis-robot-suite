# frozen_string_literal: true

# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisAssembly   # This is your workflow package name (using CamelCase)
      class ExtractIso19139 < Base
        def initialize
          super('gisAssemblyWF', 'extract-iso19139', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid = GisRobotSuite.initialize_robot druid
          LyberCore::Log.debug "extract-iso19139 working on #{druid}"

          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage

          # See if generation is needed
          fn = File.join(rootdir, 'metadata', 'geoMetadata.xml')
          if File.size?(fn)
            LyberCore::Log.info "extract-iso19139: #{druid} found #{fn}"
            return
          end

          begin
            fn = GisRobotSuite.locate_esri_metadata "#{rootdir}/temp"
            if fn =~ /^(.*).(shp|tif).xml$/ || fn =~ %r{^(.*/metadata).xml$}
              ofn = Regexp.last_match(1) + '-iso19139.xml'
              ofn_fc = Regexp.last_match(1) + '-iso19110.xml'
              ofn_fgdc = Regexp.last_match(1) + '-fgdc.xml'
            end
            LyberCore::Log.debug "extract-iso19139 working on #{fn}"
            arcgis_to_iso19139 fn, ofn, ofn_fc, ofn_fgdc
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
        }

        # XSLT processor
        XSLTPROC = 'xsltproc --novalid --xinclude'
        # XML cleaner
        XMLLINT = 'xmllint --format --xinclude --nsclean'

        # Converts an ESRI ArcCatalog metadata.xml into ISO 19139
        # @param [String] fn Input file
        # @param [String] ofn Output file
        # @param [String] ofn_fc Output file for the Feature Catalog (optional)
        def arcgis_to_iso19139(fn, ofn, ofn_fc = nil, ofn_fgdc = nil)
          LyberCore::Log.debug "generating #{ofn}"
          system("#{XSLTPROC} #{XSLT[:arcgis]} '#{fn}' | #{XMLLINT} -o '#{ofn}' -") or fail
          unless ofn_fc.nil?
            LyberCore::Log.debug "generating #{ofn_fc}"
            system("#{XSLTPROC} #{XSLT[:arcgis_fc]} '#{fn}' | #{XMLLINT} -o '#{ofn_fc}' -") or fail
          end
          unless ofn_fgdc.nil?
            LyberCore::Log.debug "generating #{ofn_fgdc}"
            system("#{XSLTPROC} #{XSLT[:arcgis_fgdc]} '#{fn}' | #{XMLLINT} -o '#{ofn_fgdc}' -") or fail
          end
        end
      end
    end
  end
end
