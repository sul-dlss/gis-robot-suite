# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class ApproveMetadata < Base
        def initialize
          super('gisAssemblyWF', 'approve-metadata')
        end

        def perform_work
          raise 'not implemented'
        end
      end
    end
  end
end
