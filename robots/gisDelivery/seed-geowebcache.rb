# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module GisDelivery   # This is your workflow package name (using CamelCase)

      class SeedGeowebcache # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 

        def initialize
          super('dor', 'gisDeliveryWF', 'seed-geowebcache', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "seed-geowebcache working on #{druid}"
          
          # Remote Address:171.67.35.173:80
          # Request URL:http://kurma-podd1.stanford.edu/geoserver/gwc/rest/seed/druid:bq621wf4873
          # Request Method:POST
          # Status Code:200 OK
          # Request Headersview source
          # Accept:text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
          # Accept-Encoding:gzip,deflate
          # Accept-Language:en-US,en;q=0.8
          # Cache-Control:max-age=0
          # Connection:keep-alive
          # Content-Length:152
          # Content-Type:application/x-www-form-urlencoded
          # Cookie:JSESSIONID=514C01AF5A2AF088D8224A3059379581; _ga=GA1.2.667756165.1404843603
          # Host:kurma-podd1.stanford.edu
          # Origin:http://kurma-podd1.stanford.edu
          # Referer:http://kurma-podd1.stanford.edu/geoserver/gwc/rest/seed/druid:bq621wf4873
          # User-Agent:Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.101 Safari/537.36
          # Form Dataview sourceview URL encoded
          # threadCount:01
          # type:seed
          # gridSetId:EPSG:900913
          # format:image/png
          # zoomStart:00
          # zoomStop:10
          # parameter_STYLES:druid_bq621wf48733
          # minX:
          # minY:
          # maxX:
          # maxY:
          # Response Headersview source
          # Connection:Keep-Alive
          # Content-Encoding:gzip
          # Content-Length:981
          # Content-Type:text/html;charset=ISO-8859-1
          # Date:Wed, 15 Oct 2014 20:38:33 GMT
          # Keep-Alive:timeout=5, max=100
          # Server:Noelios-Restlet-Engine/1.0..8
          
          
          raise NotImplementedError # XXX: seed tiles using geoserver's built-in geowebcache
        end
      end

    end
  end
end
