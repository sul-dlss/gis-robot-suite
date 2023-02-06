# frozen_string_literal: true

module Robots
  module DorRepo
    module GisAssembly
      class ApproveData < Base
        def initialize
          super('gisAssemblyWF', 'approve-data')
        end

        def perform_work
          raise 'not implemented'
        end
      end
    end
  end
end
