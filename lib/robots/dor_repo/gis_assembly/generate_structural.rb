# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class GenerateStructural < Base
        def initialize
          super('gisAssemblyWF', 'generate-structural')
        end

        def perform_work
          nil # nothing to do
        end
      end
    end
  end
end
