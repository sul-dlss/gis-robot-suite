# frozen_string_literal: true

module GisRobotSuite
  # Generates Cloud Optimized GeoTIFF (COG) derivatives.
  class CogGenerator
    def self.generate(input_path:, output_path:, unit: nil, logger: nil)
      new(input_path: input_path, output_path: output_path, unit: unit, logger: logger).generate
    end

    # @param [String] unit the unit the band values are in, e.g. "m". GDAL records it as the
    #   band's unit type, which is the only place a COG can say what its values measure.
    def initialize(input_path:, output_path:, unit: nil, logger: nil)
      @input_path = input_path
      @output_path = output_path
      @unit = unit
      @logger = logger
    end

    def generate
      return convert_to_cog(input_path) if unit.blank?

      convert_with_unit
    end

    private

    attr_reader :input_path, :output_path, :unit, :logger

    # `gdal raster convert` takes no band metadata options, and a COG cannot be edited in
    # place afterwards without losing the layout that makes it a COG, so the unit has to be
    # set on the conversion's input. A VRT carries it without copying any raster data and
    # leaves the master alone -- editing the master would invalidate the checksums cocina
    # recorded for it during assembly.
    def convert_with_unit
      vrt_path = output_path.parent / "#{File.basename(output_path.to_s, '.tif')}.vrt"

      begin
        convert_to_vrt(vrt_path)
        declare_unit(vrt_path)
        convert_to_cog(vrt_path)
      ensure
        FileUtils.rm_f(vrt_path)
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

    def convert_to_vrt(vrt_path)
      command = "gdal raster convert --overwrite --format=VRT #{Shellwords.escape(input_path.to_s)} #{Shellwords.escape(vrt_path.to_s)}"
      GisRobotSuite.run_system_command(command, logger: logger)
    end

    def convert_to_cog(path)
      command = "gdal raster convert --overwrite --format=COG --co TILING_SCHEME=GoogleMapsCompatible #{Shellwords.escape(path.to_s)} #{Shellwords.escape(output_path.to_s)}"
      GisRobotSuite.run_system_command(command, logger: logger)
    end
  end
end
