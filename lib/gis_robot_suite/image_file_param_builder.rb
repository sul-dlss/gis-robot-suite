# frozen_string_literal: true

module GisRobotSuite
  # A specialized subclass of FileParamBuilder for building the Cocina File metadata for an image file.
  class ImageFileParamBuilder < FileParamBuilder
    # @return [Hash<Symbol, Object>]
    def self.build(presentation:, **)
      new(presentation:, **).build
    end

    def initialize(presentation:, **)
      super(**)
      @presentation = presentation
    end

    attr_reader :presentation

    def build
      super.tap do |params|
        params[:presentation] = presentation
      end
    end
  end
end
