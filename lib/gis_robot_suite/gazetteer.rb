# frozen_string_literal: true

# Gazetteer data look like this:
#   "l_kw","lc_id"
#   "Ahmadābād District (India)","n78019943"
module GisRobotSuite
  class Gazetteer
    CSV_FN = File.join(File.dirname(__FILE__), 'gazetteer.csv')
    LOC_NAMES_URI = 'http://id.loc.gov/authorities/names/'
    LOC_SUBJECTS_URI = 'http://id.loc.gov/authorities/subjects/'

    def initialize
      @registry = {}
      CSV.foreach(CSV_FN, encoding: 'UTF-8', headers: true) do |row|
        keyword = row['l_kw']&.strip
        lc_id = row['lc_id']&.strip
        lc_id = nil if lc_id == ''
        @registry[keyword] = lc_id unless keyword.nil? || keyword.empty?
      end
    end

    # @return [Hash, nil] properties for a Cocina place subject
    def find_placename(keyword)
      lc_id = @registry[keyword.strip]
      return nil if lc_id.nil? || lc_id.empty?

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
      @registry.include?(keyword) && @registry[keyword].nil?
    end
  end
end
