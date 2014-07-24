# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisAssembly   # This is your workflow package name (using CamelCase)

      class PackageData # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 

        def initialize
          super('dor', 'gisAssemblyWF', 'package-data', check_queued_status: true) # init LyberCore::Robot
        end

        # Create data.zip for all shapefiles
        def generate_data_zip(rootdir)
          File.umask(002)

          # XXX: only works for shapefiles 
          Dir.glob(File.join(rootdir, 'temp', '**', '*.shp')) do |shp|
            basename = File.basename(shp, '.shp')
            zipfn = File.join(rootdir, 'content', 'data.zip')
            LyberCore::Log.debug "Compressing #{basename} into #{zipfn}"
            fns = Dir.glob(File.join(File.dirname(shp), "#{basename}.*")).select do |fn|
              fn !~ /\.zip$/
            end
            Dir.glob(File.join(File.dirname(shp), "#{basename}-*.xml")).each do |fn|
              fns << fn
            end
            system "mkdir -p #{File.dirname(zipfn)}" unless File.directory?(File.dirname(zipfn))
            system "zip -vj '#{zipfn}' #{fns.join(' ')}"
          end
        
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "package-data working on #{druid}"
          
          rootdir = GisRobotSuite.druid_path druid, type: :stage
          raise ArgumentError, "Missing #{rootdir}" unless File.directory?(rootdir)
          generate_data_zip rootdir
        end        
      end
    end
  end
end
