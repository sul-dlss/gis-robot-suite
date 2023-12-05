# frozen_string_literal: true

require 'csv'

# Gazetteer data look like this:
#   "l_kw","geonames_kw","geonames_id","lc_kw","lc_id"
#   "Ahmadābād District (India)","Ahmadābād",1279234,"Ahmadābād (India : District)","n78019943"
module GisRobotSuite
  class Gazetteer
    CSV_FN = File.join(File.dirname(__FILE__), 'gazetteer.csv')

    def initialize
      @registry = {}
      CSV.foreach(CSV_FN, encoding: 'UTF-8', headers: true) do |row|
        row = row.each { |_k, v2| v2.to_s.strip } # rubocop:disable Style/HashEachMethods rubocop thinks row is a regular Hash; it's not, and CSV::Row doesn't have #each_value
        keyword = row[0]
        keyword = row[1] if keyword.nil? || keyword.empty?
        keyword.strip!
        @registry[keyword] = {
          geonames_placename: row[1],
          geonames_id: row[2].to_i,
          # rubocop:disable Style/TernaryParentheses
          loc_keyword: (row[3].nil? || row[3].empty?) ? nil : row[3],
          loc_id: (row[4].nil? || row[4].empty?) ? nil : row[4]
          # rubocop:enable Style/TernaryParentheses
        }
        if @registry[keyword][:geonames_placename].nil? &&
           @registry[keyword][:loc_keyword].nil?
          @registry[keyword] = nil
        end
      end
    end

    def each(&)
      @registry.each_key.to_a.sort.each(&)
    end

    # @return <String> geonames name
    def find_placename(keyword)
      _get(keyword, :geonames_placename)
    end

    # @return <Integer> geonames id
    def find_id(keyword)
      _get(keyword, :geonames_id)
    end

    # @return <String> library of congress name
    def find_loc_keyword(keyword)
      _get(keyword, :loc_keyword)
    end

    # @return <String> library of congress valueURI
    def find_loc_uri(keyword)
      lcid = _get(keyword, :loc_id)
      case lcid
      when /^lcsh:(\d+)$/, /^sh(\d+)$/
        "http://id.loc.gov/authorities/subjects/sh#{Regexp.last_match(1)}"
      when /^lcnaf:(\d+)$/, /^n(\d+)$/
        "http://id.loc.gov/authorities/names/n#{Regexp.last_match(1)}"
      when /^no(\d+)$/
        "http://id.loc.gov/authorities/names/no#{Regexp.last_match(1)}"
      end
    end

    # @return <String> authority name
    def find_loc_authority(keyword)
      lcid = _get(keyword, :loc_id)
      return Regexp.last_match(1) if lcid =~ /^(lcsh|lcnaf):/
      return 'lcsh' if lcid =~ /^sh\d+$/
      return 'lcnaf' if lcid =~ /^(n|no)\d+$/
      return 'lcsh' unless find_loc_keyword(keyword).nil? # default to lcsh if present

      nil
    end

    # @see http://www.geonames.org/ontology/documentation.html
    # @return <String> geonames uri (includes trailing / as specified)
    def find_placename_uri(keyword)
      return nil if _get(keyword, :geonames_id).nil?

      "http://sws.geonames.org/#{_get(keyword, :geonames_id)}/"
    end

    # @return <String> The keyword
    def find_keyword_by_id(id)
      @registry.each do |keyword, val|
        return keyword if !val.nil? && val[:geonames_id] == id
      end
      nil
    end

    def blank?(keyword)
      @registry.include?(keyword) && @registry[keyword].nil?
    end

    private

    def _get(keyword, hash_key)
      return nil unless @registry.include?(keyword.strip)
      raise ArgumentError unless hash_key.is_a? Symbol

      @registry[keyword.strip].nil? ? nil : @registry[keyword.strip][hash_key]
    end
  end
end
