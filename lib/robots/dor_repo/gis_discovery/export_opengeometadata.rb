require 'json'

# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisDiscovery   # This is your workflow package name (using CamelCase)
      class ExportOpengeometadata < Base
        def initialize
          super('gisDiscoveryWF', 'export-opengeometadata', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          druid = GisRobotSuite.initialize_robot druid
          LyberCore::Log.debug "export-opengeometadata working on #{druid}"

          stagedir = GisRobotSuite.locate_druid_path druid, type: :stage
          exportdir = Settings.geohydra.opengeometadata.dir
          FileUtils.mkdir_p(exportdir) unless File.directory?(exportdir)

          # determine export folder
          if druid =~ /^(\w{2})(\d{3})(\w{2})(\d{4})$/
            druidtree =  File.join(Regexp.last_match(1), Regexp.last_match(2), Regexp.last_match(3), Regexp.last_match(4))
          else
            fail "export-opengeometadata: Malformed druid? #{druid}"
          end
          stacksdir = File.join(Settings.geohydra.stacks || '/stacks', druidtree)

          # Read object in DOR
          item = Dor::Item.find("druid:#{druid}")

          # Update layers.json
          lockfn = File.join('/tmp', 'layers.json.LOCK') # lock must be on local filesystem
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
            json = JSON.pretty_generate(Hash[layers.keys.sort.map { |k| [k, layers[k]] }]) # sort by key
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
          xml = item.geoMetadata.ng_xml
          if xml.nil? || xml.root.nil?
            fail ArgumentError, "export-opengeometadata: #{druid} cannot parse ISO 19139 in #{ifn}"
          end

          xml.xpath('//gmd:MD_Metadata', 'xmlns:gmd' => 'http://www.isotc211.org/2005/gmd').each do |node|
            LyberCore::Log.debug "export-opengeometadata: #{druid} extracting ISO 19139"
            File.open(File.join(exportdir, 'iso19139.xml'), 'w') do |f|
              f << node.to_xml(indent: 2)
            end
          end
          xml.xpath('//gfc:FC_FeatureCatalogue', 'xmlns:gfc' => 'http://www.isotc211.org/2005/gfc').each do |node|
            LyberCore::Log.debug "export-opengeometadata: #{druid} extracting ISO 19110"
            File.open(File.join(exportdir, 'iso19110.xml'), 'w') do |f|
              f << node.to_xml(indent: 2)
            end
          end

          # Export MODS
          LyberCore::Log.debug "export-opengeometadata: #{druid} extracting MODS"
          xml = item.descMetadata.ng_xml.to_xml
          ofn = File.join(exportdir, 'mods.xml')
          File.write(ofn, xml)

          # Export preview
          LyberCore::Log.debug "export-opengeometadata: #{druid} extracting preview.jpg"
          ifn = File.join(stacksdir, 'preview.jpg')
          fail "export-opengeometadata: #{druid} cannot find preview in #{ifn}" unless File.size?(ifn)

          ofn = File.join(exportdir, 'preview.jpg')
          FileUtils.cp(ifn, ofn)

          # Export GeoBlacklight as JSON
          LyberCore::Log.debug "export-opengeometadata: #{druid} extracting GeoBlacklight"
          ifn = File.join(stagedir, 'metadata', 'geoblacklight.json')
          fail "export-opengeometadata: #{druid} cannot find GeoBlacklight in #{ifn}" unless File.size?(ifn)

          ofn = File.join(exportdir, 'geoblacklight.json')
          FileUtils.cp(ifn, ofn)
        end
      end
    end
  end
end
