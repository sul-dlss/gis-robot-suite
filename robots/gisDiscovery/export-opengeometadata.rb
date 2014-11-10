
# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisDiscovery   # This is your workflow package name (using CamelCase)

      class ExportOpengeometadata # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 

        def initialize
          super('dor', 'gisDiscoveryWF', 'export-opengeometadata', check_queued_status: true) # init LyberCore::Robot
        end

        
        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "export-opengeometadata working on #{druid}"
          
          rootdir = GisRobotSuite.locate_druid_path druid, type: :workspace

          # create export folder
          exportdir = File.join(rootdir, 'export', 'opengeometadata', 'edu.stanford.purl')
          if druid =~ /^(\w{2})(\d{3})(\w{2})(\d{4})$/
            exportdir = File.join(exportdir, $1, $2, $3, $4)
          else
            raise RuntimeError, "export-opengeometadata: Malformed druid? #{druid}"
          end
          FileUtils.mkdir_p(exportdir) unless File.directory?(exportdir)
          
          # Export ISO 19139/19110
          ifn = File.join(rootdir, 'metadata', 'geoMetadata.xml')
          xml = Nokogiri::XML(File.read(ifn))
          if xml.nil? or xml.root.nil?
            raise ArgumentError, "export-opengeometadata: #{druid} cannot parse ISO 19139 in #{ifn}" 
          end
          ofn = File.join(exportdir, 'iso19139.xml')
          xml.xpath('//gmd:MD_Metadata', 'xmlns:gmd' => 'http://www.isotc211.org/2005/gmd') do |node|
            File.open(ofn, 'w') do |f|
              f << node.to_xml(:indent => 2)
            end
          end
          ofn = File.join(exportdir, 'iso19110.xml')
          xml.xpath('//gfc:FC_FeatureCatalogue', 'xmlns:gfc' => 'http://www.isotc211.org/2005/gfc') do |node|
            File.open(ofn, 'w') do |f|
              f << node.to_xml(:indent => 2)
            end
          end
          
          # Export MODS
          ifn = File.join(rootdir, 'metadata', 'descMetadata.xml')
          ofn = File.join(exportdir, 'mods.xml')
          FileUtils.cp(ifn, ofn)
          
          # Export preview
          ifn = File.join(rootdir, 'content', 'preview.jpg')
          ofn = File.join(exportdir, 'preview.jpg')
          FileUtils.cp(ifn, ofn)
          
          # Export GeoBlacklight
          ifn = File.join(rootdir, 'metadata', 'geoblacklight')
          ofn = File.join(exportdir, 'geoblacklight.xml')
          FileUtils.cp(ifn, ofn)
        end
      end
    end
  end
end
