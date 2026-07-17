# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'json_schemer'
require 'shellwords'

module GisRobotSuite
  # Generates derivatives for index maps (GeoJSON).
  class IndexMapDerivativeGenerator
    # The OpenIndexMaps 1.0.0 JSON schema that generated GeoJSON must conform to.
    SCHEMA_PATH = File.expand_path('../../config/openindexmaps-1.0.0.schema.json', __dir__)

    # Raised when the generated GeoJSON does not conform to the OpenIndexMaps schema.
    class InvalidGeoJsonError < StandardError; end

    def self.generate(input_path:, geojson_path:, logger: nil)
      new(input_path: input_path, geojson_path: geojson_path, logger: logger).generate
    end

    def initialize(input_path:, geojson_path:, logger: nil)
      @input_path = input_path
      @geojson_path = geojson_path
      @logger = logger
    end

    def generate
      # Generate GeoJSON
      command = "gdal convert --overwrite --output-layer #{layer_name} #{Shellwords.escape(input_path.to_s)} #{Shellwords.escape(geojson_path.to_s)}"
      GisRobotSuite.run_system_command(command, logger: logger)
      validate!
    end

    private

    # Validates the generated GeoJSON against the OpenIndexMaps 1.0 schema.
    def validate!
      errors = validator.validate(geojson).map { |error| error['error'] }
      return if errors.empty?

      raise InvalidGeoJsonError,
            "Generated GeoJSON at #{geojson_path} does not conform to the OpenIndexMaps 1.0.0 schema: #{errors.first}"
    end

    def geojson
      JSON.parse(File.read(geojson_path))
    end

    def openindexmaps_schema_path
      basepath = File.absolute_path("#{__FILE__}/../../..")
      File.join(basepath, 'config', 'openindexmaps-1.0.0.schema.json')
    end

    def validator
      @validator ||= JSONSchemer.schema(JSON.parse(File.read(SCHEMA_PATH)))
    end

    def layer_name
      File.basename(geojson_path, '.geojson')
    end

    attr_reader :input_path, :geojson_path, :logger
  end
end
