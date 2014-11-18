# encoding: UTF-8

require 'rgeo'
require 'scanf'
require 'open-uri'

# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisAssembly   # This is your workflow package name (using CamelCase)

      class ExtractBoundingbox # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 

        def initialize
          super('dor', 'gisAssemblyWF', 'extract-boundingbox', check_queued_status: true) # init LyberCore::Robot
        end

        # Reads the shapefile to determine extent
        #
        # @return [Array#Float] ulx uly lrx lry
        def extent_shapefile(shp_filename)
          IO.popen("ogrinfo -ro -so -al '#{shp_filename}'") do |f|
            f.readlines.each do |line|
              if line =~ /^Extent:\s+(.*)\s+-\s+(.*)\s*$/
                ulx, uly = $1.split(/,/)
                lrx, lry = $2.split(/,/)
                return [ulx, uly, lrx, lry].map {|x| x.to_f }
              end
            end
          end
        end
                        
        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "extract-boundingbox working on #{druid}"

          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage          
          
          raise NotImplementedError
        end
        
      end      
    end
  end
end
