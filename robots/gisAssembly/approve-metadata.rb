# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisAssembly   # This is your workflow package name (using CamelCase)

      class ApproveMetadata # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 

        def initialize
          super('dor', 'gisAssemblyWF', 'approve-metadata', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "approve-metadata working on #{druid}"

          rootdir = Dor::Config.geohydra.stage
          raise ArgumentError, "Missing #{rootdir}" unless File.directory?(rootdir)

          # XXX: Use magic(5) to determine validity
          fn = Dir.glob("#{rootdir}/#{druid}/temp/*.shp.xml").first
          if fn.nil? or File.size(fn) == 0
            fn = Dir.glob("#{rootdir}/#{druid}/temp/*.tif.xml").first
            if fn.nil? or File.size(fn) == 0
              raise RuntimeError, "Missing metadata files"
            end
          end
          LyberCore::Log.debug "approve-metadata found #{fn}"
        end
      end

    end
  end
end
