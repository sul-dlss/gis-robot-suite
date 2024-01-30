# frozen_string_literal: true

module GisRobotSuite
  class ArcgisMetadataTransformer
    VALID_FORMATS = {
      'ISO19139' => {
        xslt: 'ArcGIS2ISO19139.xsl',
        output: 'iso19139.xml'
      },
      'ISO19110' => {
        xslt: 'arcgis_to_iso19110.xsl',
        output: 'iso19110.xml'
      },
      'FGDC' => {
        xslt: 'ArcGIS2FGDC.xsl',
        output: 'fgdc.xml'
      }
    }.freeze

    def self.transform(druid, format, logger: nil)
      new(druid, format, logger).transform
    end

    def initialize(druid, format, logger)
      @druid = druid
      @format = format.upcase
      @logger = logger

      raise "ArcgisMetadataTransformer: #{format} is not a valid format" unless VALID_FORMATS.key?(format)
    end

    def transform
      logger&.info("extract-#{format}-metadata: generating #{output_file} using #{xslt_file}")
      return if format == 'ISO19110' && data_type != 'Shapefile'

      system("#{xslt_command} #{xslt_file} '#{esri_metadata_file}' | #{xml_lint_command} -o '#{output_file}' -", exception: true)
    end

    attr_reader :druid, :format, :logger

    private

    def xslt_file
      File.join(xslt_path, VALID_FORMATS[format][:xslt]) if VALID_FORMATS.key?(format)
    end

    def output_file
      File.join(staging_dir, 'temp', "#{layer_name}-#{VALID_FORMATS[format][:output]}") if VALID_FORMATS.key?(format)
    end

    # Staging directory for this object
    def staging_dir
      GisRobotSuite.locate_druid_path(druid, type: :stage)
    end

    # XML metadata file exported from ArcGIS
    def esri_metadata_file
      GisRobotSuite.locate_esri_metadata(File.join(staging_dir, 'temp'))
    rescue RuntimeError => e
      logger&.error "extract-#{format}-metadata: #{bare_druid} is missing ESRI metadata file"
      raise e
    end

    # Type of GIS data for this object
    def data_type
      file_name = File.basename(esri_metadata_file)
      return 'ArcGRID' if file_name == 'metadata.xml'
      return 'Shapefile' if file_name.end_with?('.shp.xml')
      return 'GeoTIFF' if file_name.end_with?('.tif.xml')

      raise "extract-#{format}-metadata: #{bare_druid} has unknown GIS data type"
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
