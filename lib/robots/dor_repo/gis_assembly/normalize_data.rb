# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class NormalizeData < Base
        def initialize
          super('gisAssemblyWF', 'normalize-data')
        end

        def perform_work
          logger.debug "normalize-data working on #{bare_druid}"

          rootdir = GisRobotSuite.locate_druid_path bare_druid, type: :stage
          data_filename = "#{rootdir}/content/data_EPSG_4326.zip"
          if File.size?(data_filename)
            logger.info "normalize-data: #{bare_druid} found existing normalized data: #{File.basename(data_filename)}"
            return
          end

          File.umask(002)
          flags = {
            overwrite_prj: true,
            tmpdir: Settings.geohydra.tmpdir
          }

          filename = "#{rootdir}/content/data.zip" # original content
          logger.debug "Processing #{bare_druid} #{filename}"

          # Determine file format
          mods_filename = "#{rootdir}/metadata/descMetadata.xml"
          raise "normalize-data: #{bare_druid} is missing MODS metadata" unless File.size?(mods_filename)

          format = GisRobotSuite.determine_file_format_from_mods mods_filename
          raise "normalize-data: #{bare_druid} cannot determine file format from MODS" if format.nil?

          # reproject based on file format information
          if GisRobotSuite.vector?(format)
            reproject_shapefile(filename, mods_filename, flags)
          elsif GisRobotSuite.raster?(format)
            projection = GisRobotSuite.determine_projection_from_mods mods_filename
            projection.gsub!('ESRI', 'EPSG')
            logger.debug "Projection = #{projection}"
            filetype = format.split('format=')[1]
            raise "normalize-data: #{bare_druid} cannot locate filetype from MODS format: #{format}" if filetype.nil?

            case filetype
            when 'GeoTIFF'
              reproject_geotiff(filename, projection, flags)
            when 'ArcGRID'
              reproject_arcgrid(filename, projection, flags)
            else
              raise "normalize-data: #{bare_druid} has unsupported Raster file format: #{format}"
            end
          else
            raise "normalize-data: #{bare_druid} has unsupported file format: #{format}"
          end
        end

        def system_with_check(cmd)
          logger.debug "normalize-data: running: #{cmd}"
          success = system(cmd)
          raise "normalize-data: could not execute command successfully: #{success}: #{cmd}" unless success

          success
        end

        def extract_data_from_zip(zipfn, tmpdir)
          logger.debug "Extracting #{bare_druid} data from #{zipfn}"
          raise "normalize-data: #{bare_druid} cannot locate packaged data: #{zipfn}" unless File.size?(zipfn)

          tmpdir = File.join(tmpdir, "normalize_#{bare_druid}")
          FileUtils.rm_rf(tmpdir) if File.directory?(tmpdir)
          FileUtils.mkdir_p(tmpdir)
          system_with_check("unzip -o '#{zipfn}' -d '#{tmpdir}'")
          tmpdir
        end

        # XXX: need to verify whether raster data are continous or discrete to choose the correct resampling method
        def reproject(ifn, ofn, srid, tiffname, proj, resample = 'bilinear')
          FileUtils.mkdir_p(File.dirname(ofn)) unless File.directory?(File.dirname(ofn))
          if proj == "EPSG:#{srid}"
            # just compress with gdal_translate
            logger.info "normalize-data: #{bare_druid} is compressing original #{proj}"
            system_with_check("#{Settings.gdal_path}gdal_translate -a_srs EPSG:#{srid} #{ifn} #{ofn} -co 'COMPRESS=LZW'")
          else
            tempfn = "#{File.dirname(ofn)}/#{tiffname}_uncompressed.tif"

            # reproject with gdalwarp (must uncompress here to prevent bloat)
            logger.info "normalize-data: #{bare_druid} projecting #{File.basename(ifn)} from #{proj}"
            system_with_check "#{Settings.gdal_path}gdalwarp -r #{resample} -t_srs EPSG:#{srid} #{ifn} #{tempfn} -co 'COMPRESS=NONE'"
            raise "normalize-data: #{bare_druid} gdalwarp failed to create #{tempfn}" unless File.size?(tempfn)

            # compress tempfn with gdal_translate
            logger.info "normalize-data: #{bare_druid} is compressing reprojection to #{proj}"
            system_with_check("#{Settings.gdal_path}gdal_translate -a_srs EPSG:#{srid} #{tempfn} #{ofn} -co 'COMPRESS=LZW'")
            FileUtils.rm_f(tempfn)
          end
          raise "normalize-data: #{bare_druid} gdal_translate failed to create #{ofn}" unless File.size?(ofn)
        end

        def convert_8bit_to_rgb(tifffn, tmpdir)
          # if using 8-bit color palette, convert into RGB
          cmd = "#{Settings.gdal_path}gdalinfo -norat -noct '#{tifffn}'"
          infotxt = IO.popen(cmd, &:readlines)
          uses_palette = false
          infotxt.each do |line|
            # Band 1 Block=4063x2 Type=Byte, ColorInterp=Palette
            if line =~ /^Band (.+) Block=(.+) Type=Byte, ColorInterp=Palette\s*$/
              uses_palette = true
              break
            end
          end
          return unless uses_palette

          logger.info "normalize-data: expanding color palette into rgb for #{tifffn}"
          tmpfn = "#{tmpdir}/raw8bit.tif"
          system_with_check("mv #{tifffn} #{tmpfn}")
          system_with_check("#{Settings.gdal_path}gdal_translate -expand rgb #{tmpfn} #{tifffn} -co 'COMPRESS=LZW'")
        end

        def compute_statistics(tifffn)
          system_with_check("#{Settings.gdal_path}gdalinfo -mm -stats -norat -noct #{tifffn}")
        end

        def zip_up(ozip, tifffn)
          FileUtils.rm_f(ozip) if File.size?(ozip)
          logger.debug "Repacking #{ozip}"
          system_with_check("zip -Dj '#{ozip}' '#{tifffn}'*")
        end

        def reproject_geotiff(zipfn, proj, flags, srid = 4326)
          tmpdir = extract_data_from_zip(zipfn, flags[:tmpdir])

          # sniff out GeoTIFF file
          tiffname = nil
          Dir.glob("#{tmpdir}/*.tif.xml") do |fn|
            tiffname = File.basename(fn, '.tif.xml')
          end
          if tiffname.nil?
            logger.debug "Removing #{tmpdir}"
            FileUtils.rm_rf(tmpdir)
            raise ArgumentError, "normalize-data: #{bare_druid} cannot locate GeoTIFF in #{tmpdir}"
          end

          ifn = "#{tmpdir}/#{tiffname}.tif"
          ofn = "#{tmpdir}/EPSG_#{srid}/#{tiffname}.tif"
          reproject(ifn, ofn, srid, tiffname, proj)

          # if using 8-bit color palette, convert into RGB
          convert_8bit_to_rgb(ofn, tmpdir)

          # compute statistics
          logger.info "normalize-data: #{bare_druid} computing statistics"
          compute_statistics(ofn)

          # package up reprojection
          ozip = File.join(File.dirname(zipfn), "data_EPSG_#{srid}.zip")
          zip_up(ozip, ofn)

          # cleanup
          logger.debug "Removing #{tmpdir}"
          FileUtils.rm_rf(tmpdir)
        end

        def reproject_arcgrid(zipfn, proj, flags, srid = 4326)
          tmpdir = extract_data_from_zip(zipfn, flags[:tmpdir])

          # Sniff out ArcGRID location
          gridname = nil
          Dir.glob("#{tmpdir}/*/metadata.xml") do |fn|
            gridname = File.basename(File.dirname(fn))
          end
          if gridname.nil?
            logger.debug "Removing #{tmpdir}"
            FileUtils.rm_rf(tmpdir)
            raise ArgumentError, "normalize-data: #{bare_druid} cannot locate ArcGRID in #{tmpdir}"
          end

          # reproject
          gridfn = "#{tmpdir}/#{gridname}"
          tifffn = "#{tmpdir}/#{gridname}.tif"
          reproject(gridfn, tifffn, srid, gridname, proj)

          # if using 8-bit color palette, convert into RGB
          convert_8bit_to_rgb(tifffn, tmpdir)

          # compute statistics
          logger.info "normalize-data: #{bare_druid} computing statistics"
          compute_statistics(tifffn)

          # package up reprojection
          ozip = File.join(File.dirname(zipfn), "data_EPSG_#{srid}.zip")
          zip_up(ozip, tifffn)

          # cleanup
          logger.debug "Removing #{tmpdir}"
          FileUtils.rm_rf(tmpdir)
        end

        # @param zipfn [String] ZIP file
        def reproject_shapefile(zipfn, mods_filename, flags, srid = 4326)
          tmpdir = extract_data_from_zip(zipfn, flags[:tmpdir])

          # Sniff out Shapefile location
          shpname = nil
          Dir.glob("#{tmpdir}/*.shp") do |fn|
            shpname = File.basename(fn, '.shp')
          end
          if shpname.nil?
            logger.debug "Removing #{tmpdir}"
            FileUtils.rm_rf(tmpdir)
            raise "normalize-data: #{bare_druid} cannot locate Shapefile in #{tmpdir}"
          end

          # setup
          wkt = URI.open("https://spatialreference.org/ref/epsg/#{srid}/prettywkt/").read
          ifn = File.join(tmpdir, "#{shpname}.shp") # input shapefile
          raise "normalize-data: #{bare_druid} is missing Shapefile: #{ifn}" unless File.exist? ifn

          odr = File.join(tmpdir, "EPSG_#{srid}") # output directory
          ofn = File.join(odr, "#{shpname}.shp")  # output shapefile

          # Verify source projection
          prjfn = File.join(tmpdir, "#{shpname}.prj")
          unless File.size?(prjfn)
            logger.warn "normalize-data: #{bare_druid} is missing projection #{prjfn}"

            # Read correct projection from MODS or geoMetadata
            # <subject>
            #   <cartographics>
            #     <scale>Scale not given.</scale>
            #     <projection>EPSG::26910</projection>
            doc = Nokogiri::XML(File.binread(mods_filename))
            p = doc.xpath('/mods:mods/mods:subject/mods:cartographics[not(@authority)]/mods:projection',
                          'xmlns:mods' => 'http://www.loc.gov/mods/v3')
            raise "normalize-data: #{bare_druid} has no native projection information in MODS" if p.nil?

            p = p.first

            logger.debug "normalize-data: #{bare_druid} reports native projection: #{p.content}"
            src_srid = p.content.gsub(/EPSG:+/, '').strip.to_i

            logger.info "normalize-data: #{bare_druid} has native projection of #{src_srid}, overwriting #{prjfn}"
            prj = open("http://spatialreference.org/ref/epsg/#{src_srid}/prj/").read
            File.open(prjfn, 'wb') { |f| f << prj }
          end

          # reproject, @see http://www.gdal.org/ogr2ogr.html
          FileUtils.mkdir_p(odr) unless File.directory?(odr)
          logger.info "normalize-data: #{bare_druid} is projecting #{File.basename(ifn)} to EPSG:#{srid}"
          system_with_check("env SHAPE_ENCODING= #{Settings.gdal_path}ogr2ogr -progress -t_srs '#{wkt}' '#{ofn}' '#{ifn}'") # prevent recoding
          raise "normalize-data: #{bare_druid} failed to reproject #{ifn}" unless File.size?(ofn)

          # normalize prj file
          if flags[:overwrite_prj] && wkt
            prj_fn = ofn.gsub('.shp', '.prj')
            logger.debug "normalize-data: #{bare_druid} overwriting #{prj_fn}"
            File.write(prj_fn, wkt)
          end

          # package up reprojection
          ozip = File.join(File.dirname(zipfn), "data_EPSG_#{srid}.zip")
          FileUtils.rm_f(ozip) if File.size?(ozip)
          system_with_check("zip -Dj '#{ozip}' \"#{odr}/#{shpname}\".*")

          # cleanup
          logger.debug "normalize-data: #{bare_druid} removing #{tmpdir}"
          FileUtils.rm_rf(tmpdir)
        end
      end
    end
  end
end
