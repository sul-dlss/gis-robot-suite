# frozen_string_literal: true

module GisRobotSuite
  module DescriptiveMetadata
    class Language
      def initialize(code:, source:)
        raise 'Missing language code or code source' if code.empty? || source.empty?

        @code = code
        @source = source
      end

      attr_reader :code, :source

      def build
        raise "Unsupported language code source: #{source}." unless source == 'ISO639-2'

        { code: language_iso639_2b, source: { code: 'iso639-2b' } }
      end

      ISO_639_2B_MAP = {
        'bod' => 'tib',
        'ces' => 'cze',
        'cym' => 'wel',
        'deu' => 'ger',
        'ell' => 'gre',
        'eus' => 'baq',
        'fas' => 'per',
        'fra' => 'fre',
        'hye' => 'arm',
        'isl' => 'ice',
        'kat' => 'geo',
        'mkd' => 'mac',
        'mri' => 'mao',
        'msa' => 'may',
        'mya' => 'bur',
        'nld' => 'dut',
        'ron' => 'rum',
        'slk' => 'slo',
        'sqi' => 'alb',
        'zho' => 'chi'
      }.freeze

      private_constant :ISO_639_2B_MAP

      private

      # translates iso639-2t to iso639-2b
      def language_iso639_2b
        ISO_639_2B_MAP.fetch(code, code)
      end
    end
  end
end
