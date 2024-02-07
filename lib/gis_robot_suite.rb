# frozen_string_literal: true

module GisRobotSuite # rubocop:disable Metrics/ModuleLength
  # @return grayscale4, grayscale8, grayscale_N_M, rgb8, rgb16, rgb32
  def self.determine_raster_style(tifffn)
    info = {
      nbands: 0,
      type: 'Byte',
      min: Float::MAX,
      max: 0
    }

    # execute gdalinfo command
    IO.popen("#{Settings.gdal_path}gdalinfo -json -stats -norat -noct -nomd '#{tifffn}'") do |gdalinfo_io|
      # gdalinfo output:
      # a grayscale8 example:
      # { "bands":[{ "band":1, "type":"Byte", "colorInterpretation":"Palette", "min":1.0, "max":255.0 }] } # plus many other keys at each level
      #
      # an rgb8 example:
      # {
      #   "bands":[
      #       { "band":1, "type":"Byte", "colorInterpretation":"Red", "min":0.0, "max":232.0 },
      #       { "band":2, "type":"Byte", "colorInterpretation":"Green", "min":0.0, "max":171.0, },
      #       { "band":3, "type":"Byte", "colorInterpretation":"Blue", "min":0.0, "max":255.0 }
      #     ]
      # } # plus many other keys at each level
      gdalinfo_io.read.tap do |gdalinfo_json_str|
        gdalinfo_json = JSON.parse(gdalinfo_json_str)
        bands = gdalinfo_json['bands']

        info[:nbands] = bands.size
        info[:type] = bands.last['type']

        min_from_bands = (bands.min_by { |band| band['min'] })['min'] # the min value of all the min field values among the bands
        info[:min] = min_from_bands if min_from_bands
        max_from_bands = (bands.max_by { |band| band['max'] })['max'] # the max value of all the max field values among the bands
        info[:max] = max_from_bands if max_from_bands
      end
    end

    # determine raster style
    nbits = Math.log2([info[:min].abs, info[:max].abs].max + 1).ceil
    case info[:nbands]
    when 1
      case info[:type]
      when 'Byte'
        "grayscale#{nbits > 4 ? 8 : 4}"
      when 'Int16', 'UInt16', 'Int32', 'Float32', 'Float64'
        "grayscale_#{info[:min].floor}_#{info[:max].ceil}"
      else
        raise "Unknown 1-band raster data type: #{info[:type]}"
      end
    when 3
      case info[:type]
      when 'Byte'
        'rgb8'
      when 'Int16', 'UInt16'
        'rgb16'
      when 'Int32'
        'rgb32'
      else
        raise "Unknown 3-band raster data type: #{info[:type]}"
      end
    else
      raise "Unsupported number of bands: #{info[:nbands]}"
    end
  end

  def self.vector?(cocina_object)
    media_type(cocina_object) == 'application/x-esri-shapefile'
  end

  RASTER_TYPES = %w[image/tiff].freeze

  def self.raster?(cocina_object)
    raise "#{cocina_object.externalIdentifier} is ArcGrid format: 'application/x-ogc-aig'" if media_type(cocina_object) == 'application/x-ogc-aig'

    RASTER_TYPES.include?(media_type(cocina_object))
  end

  def self.media_type(cocina_object)
    geographic_form(cocina_object, 'media type')
  end

  def self.layertype(cocina_object)
    if vector?(cocina_object)
      'PostGIS'
    elsif raster?(cocina_object)
      'GeoTIFF'
    else
      raise "#{cocina_object.externalIdentifier} has unknown format: #{media_type(cocina_object)}"
    end
  end

  def self.data_format(cocina_object)
    geographic_form(cocina_object, 'data format')
  end

  def self.geographic_form(cocina_object, type)
    cocina_object.description.geographic&.first&.form&.find { |form| form.type == type }&.value
  end
  private_class_method :geographic_form

  def self.locate_druid_path(druid, opts = {})
    rootdir = '.'
    pid = druid.gsub(/^druid:/, '')

    case opts[:type]
    when :stage
      rootdir = Settings.geohydra.stage
      rootdir = File.join(rootdir, pid)
    when :workspace
      rootdir = DruidTools::Druid.new(druid, Settings.geohydra.workspace).path
    else
      raise 'Only :stage, :workspace are supported'
    end

    raise "Missing #{rootdir}" if opts[:validate] && !File.directory?(rootdir)

    rootdir
  end

  def self.locate_esri_metadata(dir, _opts = {})
    filename = Dir.glob("#{dir}/*.shp.xml").first # Shapefile
    if filename.nil? || File.empty?(filename)
      filename = Dir.glob("#{dir}/*.tif.xml").first # GeoTIFF
      if filename.nil? || File.empty?(filename)
        filename = Dir.glob("#{dir}/*/metadata.xml").first # ArcGRID
        raise "Missing ESRI metadata files in #{dir}" if filename.nil? || File.empty?(filename)
      end
    end
    filename
  end

  def self.determine_file_format_from_mods(modsfn)
    doc = Nokogiri::XML(File.read(modsfn))
    format = doc.xpath('/mods:mods/mods:extension[@displayLabel="geo"]/*/*/dc:format',
                       'mods' => 'http://www.loc.gov/mods/v3',
                       'dc' => 'http://purl.org/dc/elements/1.1/').first
    format = format.text unless format.nil?
    format
  end

  def self.determine_rights(cocina_model)
    return 'public' if cocina_model.access.view == 'world'

    'restricted'
  end
end
