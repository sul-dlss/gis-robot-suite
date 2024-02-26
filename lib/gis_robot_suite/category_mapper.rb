# frozen_string_literal: true

module GisRobotSuite
  # Maps ISO19115 Topic Category code to label
  class CategoryMapper
    def self.label(code)
      new(code).label
    end

    # @param [String] code
    def initialize(code)
      @code = code
    end

    attr_reader :code

    CATEGORY_MAP = {
      'farming' => 'Farming',
      'biota' => 'Biology and Ecology',
      'climatologyMeteorologyAtmosphere' => 'Climatology, Meteorology and Atmosphere',
      'boundaries' => 'Boundaries',
      'economy' => 'Economy',
      'elevation' => 'Elevation',
      'environment' => 'Environment',
      'geoscientificInformation' => 'Geoscientific Information',
      'health' => 'Health',
      'imageryBaseMapsEarthCover' => 'Imagery and Base Maps',
      'intelligenceMilitary' => 'Military',
      'inlandWaters' => 'Inland Waters',
      'location' => 'Location',
      'oceans' => 'Oceans',
      'planningCadastre' => 'Planning and Cadastral',
      'structure' => 'Structure',
      'transportation' => 'Transportation',
      'utilitiesCommunication' => 'Utilities and Communication',
      'society' => 'Society'
    }.freeze

    def label
      CATEGORY_MAP.fetch(code, nil)
    end
  end
end
