# frozen_string_literal: true

module GisRobotSuite
  # Generates Cloud Optimized GeoTIFF (COG) derivatives.
  class CogGenerator
    include RasterSourceCrs
    include RasterEightBitValues

    def self.generate(input_path:, output_path:, unit: nil, fallback_crs: nil, logger: nil)
      new(input_path: input_path, output_path: output_path, unit: unit, fallback_crs: fallback_crs, logger: logger).generate
    end

    # @param [String] unit the unit the band values are in, e.g. "m". GDAL records it as the
    #   band's unit type, which is the only place a COG can say what its values measure.
    # @param [String] fallback_crs the CRS to assign the raster if it declares no usable one of its
    #   own, e.g. "EPSG:26904" (see RasterSourceCrs)
    def initialize(input_path:, output_path:, unit: nil, fallback_crs: nil, logger: nil)
      @input_path = input_path
      @output_path = output_path
      @unit = unit
      @fallback_crs = fallback_crs
      @logger = logger
    end

    def generate
      return convert_to_cog(input_path) if unit.blank? && crs_to_assign.nil? && !eight_bit_values?

      convert_via_vrt
    end

    private

    attr_reader :input_path, :output_path, :unit, :fallback_crs, :logger

    # `gdal raster convert` takes no band metadata, CRS or data type options, and a COG cannot be
    # edited in place afterwards without losing the layout that makes it a COG, so the unit, any CRS
    # the raster lacks, and a conversion to Byte (see RasterEightBitValues) have to be set on the
    # conversion's input. VRTs carry them without copying any raster data and leave the master
    # alone -- editing the master would invalidate the checksums cocina recorded for it during assembly.
    def convert_via_vrt
      basename = File.basename(output_path.to_s, '.tif')
      vrt_path = output_path.parent / "#{basename}.vrt"
      byte_vrt_path = output_path.parent / "#{basename}_byte.vrt"

      begin
        write_source_vrt(vrt_path)
        source = vrt_path
        if eight_bit_values?
          write_byte_vrt(vrt_path, byte_vrt_path)
          source = byte_vrt_path
        end
        declare_unit(source) if unit.present?
        convert_to_cog(source)
      ensure
        FileUtils.rm_f([vrt_path, byte_vrt_path])
      end
    end

    # GDAL reads a band's unit from the VRT's <UnitType> and writes it through to the COG's
    # GDALMetadata tag, where gdalinfo reports it as "Unit Type".
    def declare_unit(vrt_path)
      logger&.info("Recording #{unit} as the band unit of #{output_path}")

      vrt = Nokogiri::XML(vrt_path.read)
      vrt.xpath('/VRTDataset/VRTRasterBand').each do |band|
        unit_type = Nokogiri::XML::Node.new('UnitType', vrt)
        unit_type.content = unit
        band.prepend_child(unit_type)
      end
      vrt_path.write(vrt.to_xml)
    end

    def convert_to_cog(path)
      command = "gdal raster convert --overwrite --format=COG --co TILING_SCHEME=GoogleMapsCompatible #{Shellwords.escape(path.to_s)} #{Shellwords.escape(output_path.to_s)}"
      GisRobotSuite.run_system_command(command, logger: logger)
    end
  end
end
