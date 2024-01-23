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

          data_filename = "#{rootdir}/content/data_EPSG_4326.zip"
          if File.size?(data_filename)
            logger.info "normalize-data: #{bare_druid} found existing normalized data: #{File.basename(data_filename)}"
            return
          end

          File.umask(002)

          filename = "#{rootdir}/content/data.zip" # original content
          logger.debug "Processing #{bare_druid} #{filename}"

          # reproject based on file format information
          if GisRobotSuite.vector?(cocina_object)
            reproject_shapefile(filename)
          elsif GisRobotSuite.raster?(cocina_object)
            projection = GisRobotSuite.determine_projection(cocina_object)
            projection.gsub!('ESRI', 'EPSG')
            logger.debug "Projection = #{projection}"

            case GisRobotSuite.data_format(cocina_object)
            when 'GeoTIFF'
              reproject_geotiff(filename, projection)
            when 'ArcGRID'
              reproject_arcgrid(filename, projection)
            when nil
              raise "normalize-data: #{bare_druid} cannot locate data type"
            else
              raise "normalize-data: #{bare_druid} has unsupported Raster data type: #{GisRobotSuite.data_type(cocina_object)}"
            end
          else
            raise "normalize-data: #{bare_druid} has unsupported media type: #{GisRobotSuite.media_type(cocina_object)}"
          end
        end

        def rootdir
          @rootdir ||= GisRobotSuite.locate_druid_path bare_druid, type: :stage
        end

        def system_with_check(cmd)
          logger.debug "normalize-data: running: #{cmd}"
          success = system(cmd)
          raise "normalize-data: could not execute command successfully: #{success}: #{cmd}" unless success

          success
        end

        def extract_data_from_zip(zip_filename)
          logger.debug "Extracting #{bare_druid} data from #{zip_filename}"
          raise "normalize-data: #{bare_druid} cannot locate packaged data: #{zip_filename}" unless File.size?(zip_filename)

          tmpdir = File.join(Settings.geohydra.tmpdir, "normalize_#{bare_druid}")
          FileUtils.rm_rf(tmpdir) if File.directory?(tmpdir)
          FileUtils.mkdir_p(tmpdir)
          system_with_check("unzip -o '#{zip_filename}' -d '#{tmpdir}'")
          tmpdir
        end

        def reproject_raster(input_filename, output_filename, tiffname, projection)
          FileUtils.mkdir_p(File.dirname(output_filename)) unless File.directory?(File.dirname(output_filename))
          if projection == 'EPSG:4326'
            # just compress with gdal_translate
            logger.info "normalize-data: #{bare_druid} is compressing original #{projection}"
            system_with_check("#{Settings.gdal_path}gdal_translate -a_srs EPSG:4326 #{input_filename} #{output_filename} -co 'COMPRESS=LZW'")
          else
            temp_filename = "#{File.dirname(output_filename)}/#{tiffname}_uncompressed.tif"

            # reproject with gdalwarp (must uncompress here to prevent bloat)
            logger.info "normalize-data: #{bare_druid} projecting #{File.basename(input_filename)} from #{projection}"
            system_with_check "#{Settings.gdal_path}gdalwarp -r bilinear -t_srs EPSG:4326 #{input_filename} #{temp_filename} -co 'COMPRESS=NONE'"
            raise "normalize-data: #{bare_druid} gdalwarp failed to create #{temp_filename}" unless File.size?(temp_filename)

            # compress temp_filename with gdal_translate
            logger.info "normalize-data: #{bare_druid} is compressing reprojection to #{projection}"
            system_with_check("#{Settings.gdal_path}gdal_translate -a_srs EPSG:4326 #{temp_filename} #{output_filename} -co 'COMPRESS=LZW'")
            FileUtils.rm_f(temp_filename)
          end
          raise "normalize-data: #{bare_druid} gdal_translate failed to create #{output_filename}" unless File.size?(output_filename)
        end

        def convert_8bit_to_rgb(tiff_filename, tmpdir)
          # if using 8-bit color palette, convert into RGB
          cmd = "#{Settings.gdal_path}gdalinfo -norat -noct '#{tiff_filename}'"
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

          logger.info "normalize-data: expanding color palette into rgb for #{tiff_filename}"
          temp_filename = "#{tmpdir}/raw8bit.tif"
          system_with_check("mv #{tiff_filename} #{temp_filename}")
          system_with_check("#{Settings.gdal_path}gdal_translate -expand rgb #{temp_filename} #{tiff_filename} -co 'COMPRESS=LZW'")
        end

        def compute_statistics(tiff_filename)
          system_with_check("#{Settings.gdal_path}gdalinfo -mm -stats -norat -noct #{tiff_filename}")
        end

        def zip_up(output_zip, tiff_filename)
          FileUtils.rm_f(output_zip) if File.size?(output_zip)
          logger.debug "Repacking #{output_zip}"
          system_with_check("zip -Dj '#{output_zip}' '#{tiff_filename}'*")
        end

        def reproject_geotiff(zip_filename, projection)
          tmpdir = extract_data_from_zip(zip_filename)

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

          input_filename = "#{tmpdir}/#{tiffname}.tif"
          output_filename = "#{tmpdir}/EPSG_4326/#{tiffname}.tif"
          reproject_raster(input_filename, output_filename, tiffname, projection)

          # if using 8-bit color palette, convert into RGB
          convert_8bit_to_rgb(output_filename, tmpdir)

          # compute statistics
          logger.info "normalize-data: #{bare_druid} computing statistics"
          compute_statistics(output_filename)

          # package up reprojection
          output_zip = File.join(File.dirname(zip_filename), 'data_EPSG_4326.zip')
          zip_up(output_zip, output_filename)

          # cleanup
          logger.debug "Removing #{tmpdir}"
          FileUtils.rm_rf(tmpdir)
        end

        def reproject_arcgrid(zip_filename, projection)
          tmpdir = extract_data_from_zip(zip_filename)

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
          grid_filename = "#{tmpdir}/#{gridname}"
          tiff_filename = "#{tmpdir}/#{gridname}.tif"
          reproject_raster(grid_filename, tiff_filename, gridname, projection)

          # if using 8-bit color palette, convert into RGB
          convert_8bit_to_rgb(tiff_filename, tmpdir)

          # compute statistics
          logger.info "normalize-data: #{bare_druid} computing statistics"
          compute_statistics(tiff_filename)

          # package up reprojection
          output_zip = File.join(File.dirname(zip_filename), 'data_EPSG_4326.zip')
          zip_up(output_zip, tiff_filename)

          # cleanup
          logger.debug "Removing #{tmpdir}"
          FileUtils.rm_rf(tmpdir)
        end

        # @param zip_filename [String] ZIP file
        def reproject_shapefile(zip_filename)
          tmpdir = extract_data_from_zip(zip_filename)

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
          input_filename = File.join(tmpdir, "#{shpname}.shp") # input shapefile
          raise "normalize-data: #{bare_druid} is missing Shapefile: #{input_filename}" unless File.exist? input_filename

          output_dir = File.join(tmpdir, 'EPSG_4326')
          output_filename = File.join(output_dir, "#{shpname}.shp") # output shapefile

          # Verify source projection
          projection_filename = File.join(tmpdir, "#{shpname}.prj")
          unless File.size?(projection_filename)
            logger.warn "normalize-data: #{bare_druid} is missing projection #{projection_filename}"
            raise "normalize-data: #{bare_druid} has no native projection information in MODS" if projection_from_cocina.nil?

            logger.debug "normalize-data: #{bare_druid} reports native projection: #{projection_from_cocina}"
            src_srid = projection_from_cocina.gsub(/EPSG:+/, '').strip.to_i

            logger.info "normalize-data: #{bare_druid} has native projection of #{src_srid}, overwriting #{projection_filename}"
            prj = open("http://spatialreference.org/ref/epsg/#{src_srid}/prj/").read
            File.open(projection_filename, 'wb') { |f| f << prj }
          end

          # reproject, @see http://www.gdal.org/ogr2ogr.html
          FileUtils.mkdir_p(output_dir) unless File.directory?(output_dir)
          logger.info "normalize-data: #{bare_druid} is projecting #{File.basename(input_filename)} to EPSG:4326"
          system_with_check("env SHAPE_ENCODING= #{Settings.gdal_path}ogr2ogr -progress -t_srs '#{wkt}' '#{output_filename}' '#{input_filename}'") # prevent recoding
          raise "normalize-data: #{bare_druid} failed to reproject #{input_filename}" unless File.size?(output_filename)

          # normalize prj file
          projection_filename = output_filename.gsub('.shp', '.prj')
          logger.debug "normalize-data: #{bare_druid} overwriting #{projection_filename}"
          File.write(projection_filename, wkt)

          # package up reprojection
          output_zip = File.join(File.dirname(zip_filename), 'data_EPSG_4326.zip')
          FileUtils.rm_f(output_zip) if File.size?(output_zip)
          system_with_check("zip -Dj '#{output_zip}' \"#{output_dir}/#{shpname}\".*")

          # cleanup
          logger.debug "normalize-data: #{bare_druid} removing #{tmpdir}"
          FileUtils.rm_rf(tmpdir)
        end

        def projection_from_cocina
          @projection_from_cocina ||= cocina_object.description.form.find { |form| form.type == 'map projection' && form.source.nil? }&.value
        end

        def wkt
          # Well Known Text. It’s a text markup language for expressing geometries in vector data.
          @wkt ||= URI.open('https://spatialreference.org/ref/epsg/4326/prettywkt/').read
        end
      end
    end
  end
end
