# frozen_string_literal: true

# Gazetteer data look like this:
#   "l_kw","lc_id"
#   "Ahmadābād District (India)","n78019943"
module GisRobotSuite
  class Gazetteer
    CSV_FN = File.join(File.dirname(__FILE__), 'gazetteer.csv')
    LOC_NAMES_URI = 'http://id.loc.gov/authorities/names/'
    LOC_SUBJECTS_URI = 'http://id.loc.gov/authorities/subjects/'

    # @return [Hash, nil] properties for a Cocina place subject
    def find_placename(keyword)
      _found, lc_id = lookup(keyword)
      return nil if lc_id.blank?

      if lc_id.start_with?('sh')
        {
          uri: "#{LOC_SUBJECTS_URI}#{lc_id}",
          source: { code: 'lcsh', uri: LOC_SUBJECTS_URI }
        }
      else
        {
          uri: "#{LOC_NAMES_URI}#{lc_id}",
          source: { code: 'naf', uri: LOC_NAMES_URI }
        }
      end
    end

    def blank?(keyword)
      found, lc_id = lookup(keyword)
      found && lc_id.blank?
    end

    private

    def lookup(keyword)
      normalized_keyword = keyword.strip
      return @last_result if normalized_keyword == @last_keyword

      @last_keyword = normalized_keyword
      @last_result = [false, nil]
      CSV.foreach(CSV_FN, encoding: 'UTF-8', headers: true) do |row|
        next unless row['l_kw'] == normalized_keyword

        lc_id = row['lc_id']
        @last_result = [true, lc_id]
        break
      end
      @last_result
    end
  end
end
