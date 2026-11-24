# frozen_string_literal: true

module Robots
  module DorRepo
    module GisDerivative
      class StartAccessionWorkflow < Base
        def initialize
          super('gisDerivativeWF', 'start-accession-workflow')
        end

        def perform_work
          logger.debug "start-accession-workflow working on #{bare_druid}"
          close_version
        end
      end
    end
  end
end
