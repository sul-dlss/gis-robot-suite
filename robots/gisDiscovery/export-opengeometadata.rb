require 'json'

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
          druid = GisRobotSuite.initialize_robot druid
          LyberCore::Log.debug "export-opengeometadata working on #{druid}"
          
          rootdir = GisRobotSuite.locate_druid_path druid, type: :workspace
          exportdir = Dor::Config.geohydra.opengeometadata.dir
          FileUtils.mkdir_p(exportdir) unless File.directory?(exportdir)

          # determine export folder
          if druid =~ /^(\w{2})(\d{3})(\w{2})(\d{4})$/
            druidtree =  File.join($1, $2, $3, $4)
          else
            raise RuntimeError, "export-opengeometadata: Malformed druid? #{druid}"
          end
          
          # Update layers.json
          lockfn = File.join(exportdir, 'layers.json.LOCK')
          lockf = File.open(lockfn, 'w')
          lockf.flock(File::LOCK_EX)
          begin
            fn = File.join(exportdir, 'layers.json')
            if File.size?(fn)
              layers = JSON.parse(File.open(fn).read)
            else
              layers = {}
            end
            LyberCore::Log.debug "export-opengeometadata: #{druid} updating layers.json"
            layers["druid:#{druid}"] = druidtree
            json = JSON.pretty_generate(layers)
            File.open(fn, 'w') do |f|
              f << json
            end
          ensure
            lockf.flock(File::LOCK_UN)
            lockf.close
            begin
              File.unlink(lockfn) if File.size?(lockfn)
            rescue => e
              # someone might delete before we can after our unlock
            end
          end
          
          # Export files
          exportdir = File.join(exportdir, druidtree)
          FileUtils.mkdir_p(exportdir) unless File.directory?(exportdir)
          
          # Export ISO 19139/19110
          ifn = File.join(rootdir, 'metadata', 'geoMetadata.xml')
          xml = Nokogiri::XML(File.read(ifn))
          if xml.nil? or xml.root.nil?
            raise ArgumentError, "export-opengeometadata: #{druid} cannot parse ISO 19139 in #{ifn}" 
          end
          
          xml.xpath('//gmd:MD_Metadata', 'xmlns:gmd' => 'http://www.isotc211.org/2005/gmd').each do |node|
            LyberCore::Log.debug "export-opengeometadata: #{druid} extracting ISO 19139"
            File.open(File.join(exportdir, 'iso19139.xml'), 'w') do |f|
              f << node.to_xml(:indent => 2)
            end
          end
          xml.xpath('//gfc:FC_FeatureCatalogue', 'xmlns:gfc' => 'http://www.isotc211.org/2005/gfc').each do |node|
            LyberCore::Log.debug "export-opengeometadata: #{druid} extracting ISO 19110"
            File.open(File.join(exportdir, 'iso19110.xml'), 'w') do |f|
              f << node.to_xml(:indent => 2)
            end
          end
          
          # Export HTML transformation
          # LyberCore::Log.debug "export-opengeometadata: #{druid} converting ISO 19139 to HTML"
          # system("xsltproc -o #{File.join(exportdir, 'iso19139.html')} schema/tools/iso2html/iso-html.xsl #{File.join(exportdir, 'iso19139.xml')}")
          
          # Export MODS
          LyberCore::Log.debug "export-opengeometadata: #{druid} extracting MODS"
          ifn = File.join(rootdir, 'metadata', 'descMetadata.xml')
          ofn = File.join(exportdir, 'mods.xml')
          FileUtils.cp(ifn, ofn)
          
          # Export preview
          LyberCore::Log.debug "export-opengeometadata: #{druid} extracting preview.jpg"
          ifn = File.join(rootdir, 'content', 'preview.jpg')
          ofn = File.join(exportdir, 'preview.jpg')
          FileUtils.cp(ifn, ofn)
          
          # Export GeoBlacklight
          LyberCore::Log.debug "export-opengeometadata: #{druid} extracting GeoBlacklight"
          ifn = File.join(rootdir, 'metadata', 'geoblacklight.xml')
          ofn = File.join(exportdir, 'geoblacklight.xml')
          FileUtils.cp(ifn, ofn)
        end
      end
    end
  end
end
