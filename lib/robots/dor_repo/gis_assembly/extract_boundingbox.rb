# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      # No longer does anything: extract-iso19139-metadata computes the bounding box from the data
      # and writes it into the ISO 19139, and generate-descriptive records it in cocina from there.
      #
      # Kept until the step is removed from gisAssemblyWF, so that objects already queued for it
      # can finish the workflow.
      class ExtractBoundingbox < Base
        def initialize
          super('gisAssemblyWF', 'extract-boundingbox')
        end

        def perform_work
          LyberCore::ReturnState.new(status: :skipped,
                                     note: 'bounding box is computed by extract-iso19139-metadata and recorded by generate-descriptive')
        end
      end
    end
  end
end
