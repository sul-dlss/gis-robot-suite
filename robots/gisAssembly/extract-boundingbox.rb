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

        def extract_data_from_zip druid, zipfn, tmpdir
          LyberCore::Log.info "extract-boundingbox: #{druid} is extracting data: #{zipfn}"
          
          tmpdir = File.join(tmpdir, "extractboundingbox_#{druid}")
          FileUtils.rm_rf tmpdir if File.directory? tmpdir
          FileUtils.mkdir_p tmpdir
          system("unzip '#{zipfn}' -d '#{tmpdir}'")
          tmpdir
        end

        # Reads the shapefile to determine extent
        #
        # @return [Array#Float] ulx uly lrx lry
        def extent_shapefile(shpfn)
          LyberCore::Log.debug "extract-boundingbox: working on Shapefile: #{shpfn}"
          IO.popen("ogrinfo -ro -so -al '#{shpfn}'") do |f|
            f.readlines.each do |line|
              # Extent: (-151.479444, 26.071745) - (-78.085007, 69.432500)
              if line =~ /^Extent:\s+\((.*)\)\s+-\s+\((.*)\)/
                lr, ul = [$1, $2].map {|x| x.to_s}
                ulx, uly = ul.split(/,/)
                lrx, lry = lr.split(/,/)
                return [ulx, uly, lrx, lry].map {|x| x.to_s.strip.to_f }
              end
            end
          end
        end
        
        # Reads the GeoTIFF to determine extent
        #
        # @return [Array#Float] ulx uly lrx lry
        def extent_geotiff(tiffn)
          LyberCore::Log.debug "extract-boundingbox: working on GeoTIFF: #{tiffn}"
          IO.popen("gdalinfo '#{shp_filename}'") do |f|
            f.readlines.each do |line|
              # Corner Coordinates:
              # Upper Left  (-122.2846400,  35.9770286) (122d17' 4.70"W, 35d58'37.30"N)
              # Lower Left  (-122.2846400,  35.5581835) (122d17' 4.70"W, 35d33'29.46"N)
              # Upper Right (-121.9094764,  35.9770286) (121d54'34.12"W, 35d58'37.30"N)
              # Lower Right (-121.9094764,  35.5581835) (121d54'34.12"W, 35d33'29.46"N)
              # Center      (-122.0970582,  35.7676061) (122d 5'49.41"W, 35d46' 3.38"N)              
              if line =~ /^Upper Left\s+\((.*)\)/
                ulx, uly = $1.split(/,/)
              elsif line =~ /^Lower Right\s+\((.*)\)/
                lrx, lry = $1.split(/,/)
              end
            end
            return [ulx, uly, lrx, lry].map {|x| x.to_s.strip.to_f }
          end
        end

        
        def rewrite_mods(modsfn, ulx, uly, lrx, lry)
          doc = Nokogiri::XML(File.open(modsfn, 'rb').read)
          
          # Modify geo extension
          doc.xpath('/mods:mods/mods:extension[@displayLabel="geo"]/rdf:RDF/rdf:Description/gml:boundedBy/gml:Envelope',
            'xmlns:mods' => 'http://www.loc.gov/mods/v3',
            'xmlns:rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
            'xmlns:gml' => 'http://www.opengis.net/gml/3.2/'
          ).each do |node|
            node['gml:srsName'] = 'ESPG:4326'
            node.xpath('gml:upperCorner', 'xmlns:gml' => 'http://www.opengis.net/gml/3.2/').each do |x|
              x.content = [ulx, uly].join(' ')
            end
            node.xpath('gml:lowerCorner', 'xmlns:gml' => 'http://www.opengis.net/gml/3.2/').each do |x|
              x.content = [lrx, lry].join(' ')
            end
          end
          
          # Add subject/cartographics for WGS84 projection
          subj = Nokogiri::XML::Node.new 'subject', doc
          carto = Nokogiri::XML::Node.new 'cartographics', doc
          scale = Nokogiri::XML::Node.new 'scale', doc
          projection = Nokogiri::XML::Node.new 'projection', doc
          coordinates = Nokogiri::XML::Node.new 'coordinates', doc

          subj['authority'] = 'EPSG'
          subj['valueURI'] = 'http://opengis.net/def/crs/EPSG/0/4326'
          subj['displayLabel'] = 'WGS84'
          scale.content = 'Scale not given.'
          projection.content = 'EPSG:4326'
          coordinates.content = "#{ulx} -- #{lrx}/#{uly} -- #{lry}"
          
          carto.add_child(scale)
          carto.add_child(projection)
          carto.add_child(coordinates)
          subj.add_child(carto)
          doc.root.add_child(subj)
          
          # Add note
          note = Nokogiri::XML::Node.new 'note', doc
          note['displayLabel'] = 'WGS84 Cartographics'
          note.content = 'This layer is presented in the WGS84 coordinate system for web display purposes. Downloadable data are provided in native coordinate system or projection.'
          doc.root.add_child(note)
          
          # Save
          File.open(modsfn, 'wb') do |f|
            f << doc.to_xml(:indent => 2)
          end
        end
        
                        
        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "extract-boundingbox working on #{druid}"

          rootdir = GisRobotSuite.locate_druid_path druid, type: :stage          
          
          modsfn = File.join(rootdir, 'metadata', 'descMetadata.xml')
          raise RuntimeError, "extract-boundingbox: #{druid} cannot locate MODS: #{modsfn}" unless File.exists?(modsfn)
          
          projection = '4326' # always use EPSG:4326 derivative
          zipfn = File.join(rootdir, 'content', "data_EPSG_#{projection}.zip")
          raise RuntimeError, "extract-boundingbox: #{druid} cannot locate normalized data: #{zipfn}" unless File.exists?(zipfn)
          tmpdir = extract_data_from_zip druid, zipfn, Dor::Config.geohydra.tmpdir
          raise RuntimeError, "extract-boundingbox: #{druid} cannot locate #{tmpdir}" unless File.directory?(tmpdir)
          
          begin
            Dir.chdir(tmpdir)
            shpfn = Dir.glob("*.shp").first
            unless shpfn.nil?
              ulx, uly, lrx, lry = extent_shapefile shpfn
            else
              tiffn = Dir.glob("*.tif").first
              ulx, uly, lrx, lry = extent_geotiff tiffn              
            end
            LyberCore::Log.debug [ulx, uly, lrx, lry].join(' -- ')
            rewrite_mods(modsfn, ulx, uly, lrx, lry)
          ensure
            LyberCore::Log.debug "Cleaning: #{tmpdir}"
            FileUtils.rm_rf tmpdir
          end          
        end

      end      
    end
  end
end
