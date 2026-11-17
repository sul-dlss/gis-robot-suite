# frozen_string_literal: true

require 'json'

module GisRobotSuite
  # Lets the COG generator "shrink" a raster that was created as 16-bit or 32-bit
  # but that contains only single-byte values be generated as an 8-bit RGBA COG with
  # corrected Nodata values. Without this, the COG will appear black because every value
  # only occupies the very low end of the spectrum.
  #
  # The including class provides `input_path`, `logger` and `run_command` (see RasterSourceCrs).
  module RasterEightBitValues
    WIDE_UNSIGNED_TYPES = { 'UInt16' => 65_535, 'UInt32' => 4_294_967_295 }.freeze
    BYTE_MAX = 255
    # Output band labels for the value bands (not counting alpha), by how many there are
    VALUE_BAND_LABELS = { 1 => %w[gray], 3 => %w[red green blue] }.freeze

    private

    # @return [Boolean] whether the raster is a gray or RGB image whose
    #   value bands hold only 0-255, but in a wider unsigned integer type
    def eight_bit_values?
      return @eight_bit_values if defined?(@eight_bit_values)

      @eight_bit_values = wide_unsigned? && VALUE_BAND_LABELS.key?(value_bands.size) &&
                          value_bands.all? { |band| band['computedMax'] && band['computedMax'] <= BYTE_MAX }
    end

    # A Byte VRT of `source` (a VRT of the raster), with its bands labelled as an image and any NoData
    # Byte can't hold turned into an alpha band
    def write_byte_vrt(source, destination)
      logger&.info("#{input_path} holds only 8-bit values in #{band_ranges.first['type']}; converting it to Byte")
      run_command 'gdal_translate', '-q', '-of', 'VRT', '-ot', 'Byte', *band_arguments, *nodata_arguments,
                  '-colorinterp', output_band_labels.join(','), source, destination
    end

    def band_arguments
      band_ranges.each_with_index.flat_map do |band, index|
        number = index + 1
        selection = ['-b', number]
        next selection unless alpha_band?(band) && band['computedMax'].to_f > BYTE_MAX

        # An alpha band spanning its type's whole range is scaled to Byte's, not clipped
        selection + ["-scale_#{number}", 0, WIDE_UNSIGNED_TYPES.fetch(band['type']), 0, BYTE_MAX]
      end + (mask_as_alpha? ? %w[-b mask] : [])
    end

    # If the nodata is already inside byte range, keep it – if it's more than
    # 256, we need to change it so it fits inside byte range
    def nodata_arguments = nodata_outside_byte? ? %w[-a_nodata none] : []

    def output_band_labels
      VALUE_BAND_LABELS.fetch(value_bands.size) + (alpha_band || mask_as_alpha? ? ['alpha'] : [])
    end

    # GDAL's mask band for the NoData value: 255 where there's data and 0 where there isn't
    def mask_as_alpha? = alpha_band.nil? && nodata_outside_byte?

    def nodata_outside_byte?
      nodata = band_ranges.first['noDataValue']
      nodata.is_a?(Numeric) && !nodata.between?(0, BYTE_MAX)
    end

    def value_bands = band_ranges.reject { |band| alpha_band?(band) }

    def alpha_band = band_ranges.find { |band| alpha_band?(band) }

    # A band labelled Alpha, or the fourth band left Undefined: ArcGIS writes an RGB scan's
    # transparency as a fourth band without labelling it
    def alpha_band?(band)
      band['colorInterpretation'] == 'Alpha' ||
        (band_ranges.size == 4 && band.equal?(band_ranges.last) && band['colorInterpretation'] == 'Undefined')
    end

    # Cheap: reads only the header, so rasters already in Byte (most of them) skip the full read below
    def wide_unsigned?
      types = band_types
      types.any? && types.all? { |type| WIDE_UNSIGNED_TYPES.key?(type) }
    end

    def band_types
      @band_types ||= JSON.parse(run_command('gdal', 'raster', 'info', '-f', 'json', input_path)[:stdout_str])
                          .fetch('bands', []).pluck('type')
    end

    # Every band's type, label, NoData and computed min/max. Reads the whole raster, so only for one
    # that's a candidate.
    def band_ranges
      @band_ranges ||= JSON.parse(run_command('gdal', 'raster', 'info', '-f', 'json', '--min-max', input_path)[:stdout_str])
                           .fetch('bands', [])
    end
  end
end
