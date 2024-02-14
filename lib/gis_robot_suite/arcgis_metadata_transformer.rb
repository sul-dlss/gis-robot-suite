# frozen_string_literal: true

module GisRobotSuite
  class ArcgisMetadataTransformer
    def self.transform(druid, xslt, output, logger: nil)
      new(druid, xslt, output, logger).transform
    end

    def initialize(druid, xslt, output, logger)
      @druid = druid
      @xslt = xslt
      @output = output
      @logger = logger
    end

    def transform
      logger&.info("extracting metadata: generating #{output_file} using #{xslt_file}")
      system("#{xslt_command} #{xslt_file} '#{esri_metadata_file}' | #{xml_lint_command} -o '#{output_file}' -", exception: true)
    end

    # Type of GIS data for this object
    def data_type
      file_name = File.basename(esri_metadata_file)
      return 'ArcGRID' if file_name == 'metadata.xml'
      return 'Shapefile' if file_name.end_with?('.shp.xml')
      return 'GeoTIFF' if file_name.end_with?('.tif.xml')
      return 'GeoJSON' if file_name.end_with?('.geojson.xml')

      raise "extracting metadata: #{bare_druid} has unknown GIS data type"
    end

    attr_reader :druid, :xslt, :output, :logger

    private

    def xslt_file
      File.join(xslt_path, xslt)
    end

    def output_file
      File.join(staging_dir, 'temp', "#{layer_name}-#{output}")
    end

    # Staging directory for this object
    def staging_dir
      GisRobotSuite.locate_druid_path(druid, type: :stage)
    end

    # XML metadata file exported from ArcGIS
    def esri_metadata_file
      GisRobotSuite.locate_esri_metadata(File.join(staging_dir, 'temp'))
    rescue RuntimeError => e
      logger&.error "extract-#{output}-metadata: #{bare_druid} is missing ESRI metadata file"
      raise e
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
      when 'GeoJSON'
        File.basename(esri_metadata_file, '.geojson.xml')
      end
    end

    # Directory where XSL transforms are located
    def xslt_path
      # Root of the project.  This is needed to find the XSLT files.
      basepath = File.absolute_path("#{__FILE__}/../../..")
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
  end
end
