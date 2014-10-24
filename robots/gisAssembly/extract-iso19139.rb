# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisAssembly   # This is your workflow package name (using CamelCase)

      class ExtractIso19139 # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 

        def initialize
          super('dor', 'gisAssemblyWF', 'extract-iso19139', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "extract-iso19139 working on #{druid}"

          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage

          fn = GisRobotSuite.locate_esri_metadata "#{rootdir}/temp"         
          if fn =~ %r{^(.*).(shp|tif).xml$} || fn =~ %r{^(.*/metadata).xml$}
            ofn = $1 + '-iso19139.xml'
            ofn_fc = $1 + '-iso19110.xml'
            ofn_fgdc = $1 + '-fgdc.xml'
          end
          LyberCore::Log.debug "extract-iso19139 working on #{fn}"
          
          arcgis_to_iso19139 fn, ofn, ofn_fc, ofn_fgdc
        end
        
        # XXX hardcoded paths
        def self.search_for_xsl(filename)
          path = %w{
            schema/lib/xslt
            /home/lyberadmin/ArcGIS/Transforms
          }
          path.unshift(File.dirname(__FILE__))
          path.each do |d|
            fn = File.join(d, filename)
            if File.exist?(fn)
              return fn
            end
          end
          raise RuntimeError, "Cannot find #{filename} in search path"
        end
        
        # XSLT file locations
        XSLT = {
          :arcgis     => self.search_for_xsl('ArcGIS2ISO19139.xsl'),
          :arcgis_fc  => self.search_for_xsl('arcgis_to_iso19110.xsl'),
          :arcgis_fgdc=> self.search_for_xsl('ArcGIS2FGDC.xsl')
        }
        
        # XSLT processor
        XSLTPROC = 'xsltproc --novalid --xinclude'
        # XML cleaner
        XMLLINT = 'xmllint --format --xinclude --nsclean'
        
        # Converts an ESRI ArcCatalog metadata.xml into ISO 19139
        # @param [String] fn Input file
        # @param [String] ofn Output file
        # @param [String] ofn_fc Output file for the Feature Catalog (optional)
        def arcgis_to_iso19139 fn, ofn, ofn_fc = nil, ofn_fgdc = nil
          LyberCore::Log.debug "generating #{ofn}"
          system("#{XSLTPROC} #{XSLT[:arcgis]} '#{fn}' | #{XMLLINT} -o '#{ofn}' -")
          unless ofn_fc.nil?
            LyberCore::Log.debug "generating #{ofn_fc}"
            system("#{XSLTPROC} #{XSLT[:arcgis_fc]} '#{fn}' | #{XMLLINT} -o '#{ofn_fc}' -")
          end
          unless ofn_fgdc.nil?
            LyberCore::Log.debug "generating #{ofn_fgdc}"
            system("#{XSLTPROC} #{XSLT[:arcgis_fgdc]} '#{fn}' | #{XMLLINT} -o '#{ofn_fgdc}' -")
          end
      
        end
        
      end

    end
  end
end
