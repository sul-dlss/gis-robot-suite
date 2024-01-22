# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class ExtractIso19139 < Base
        def initialize
          super('gisAssemblyWF', 'extract-iso19139')
        end

        def perform_work
          logger.debug "extract-iso19139 working on #{bare_druid}"

          # Generate ISO 19139 and FGDC for all data types
          generate_iso19139
          generate_fgdc

          # Only generate ISO 19110 if it's a Shapefile, which has a feature catalog
          generate_iso19110 if data_type == 'Shapefile'
        end

        private

        # Staging directory for this object
        def staging_dir
          GisRobotSuite.locate_druid_path(bare_druid, type: :stage)
        end

        # XML metadata file exported from ArcGIS
        def esri_metadata_file
          GisRobotSuite.locate_esri_metadata(File.join(staging_dir, 'temp'))
        rescue RuntimeError => e
          logger.error "extract-iso19139: #{bare_druid} is missing ESRI metadata file"
          raise e
        end

        # Type of GIS data for this object
        def data_type
          file_name = File.basename(esri_metadata_file)
          return 'ArcGRID' if file_name == 'metadata.xml'
          return 'Shapefile' if file_name.end_with?('.shp.xml')
          return 'GeoTIFF' if file_name.end_with?('.tif.xml')

          raise "extract-iso19139: #{bare_druid} has unknown GIS data type"
        end

        # Filename of the original GIS metadata without any extensions
        def layer_name
          case data_type
          when 'Shapefile'
            File.basename(esri_metadata_file, '.shp.xml')
          when 'GeoTIFF'
            File.basename(esri_metadata_file, '.tif.xml')
          when 'ArcGRID'
            File.basename(File.dirname(esri_metadata_file))
          end
        end

        # Directory where XSL transforms are located
        def xslt_path
          # Root of the project.  This is needed to find the XSLT files.
          basepath = File.absolute_path("#{__FILE__}/../../../../..")
          File.join(basepath, 'config', 'ArcGIS', 'Transforms')
        end

        # Comand to invoke xsltproc to transform XML
        def xslt_command
          'xsltproc --novalid --xinclude'
        end

        # Command to post-process transformed XML with xmllint
        def xml_lint_command
          'xmllint --format --xinclude --nsclean'
        end

        # Apply an XSL transform to the ESRI metadata file
        def transform_arcgis_metadata(output_file, xslt_name)
          xslt_file = File.join(xslt_path, xslt_name)
          logger.info("generating #{output_file} using #{xslt_file}")
          system("#{xslt_command} #{xslt_file} '#{esri_metadata_file}' | #{xml_lint_command} -o '#{output_file}' -", exception: true)
        end

        # Generate ISO 19139 metadata from ESRI metadata
        def generate_iso19139
          output_file = File.join(staging_dir, 'temp', "#{layer_name}-iso19139.xml")
          transform_arcgis_metadata(output_file, 'ArcGIS2ISO19139.xsl')
        end

        # Generate ISO 19110 metadata from ESRI metadata
        def generate_iso19110
          output_file = File.join(staging_dir, 'temp', "#{layer_name}-iso19110.xml")
          transform_arcgis_metadata(output_file, 'arcgis_to_iso19110.xsl')
        end

        # Generate FGDC metadata from ESRI metadata
        def generate_fgdc
          output_file = File.join(staging_dir, 'temp', "#{layer_name}-fgdc.xml")
          transform_arcgis_metadata(output_file, 'ArcGIS2FGDC.xsl')
        end
      end
    end
  end
end
