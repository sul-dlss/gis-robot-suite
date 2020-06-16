# frozen_string_literal: true

module Robots
  module DorRepo
    class Base
      include LyberCore::Robot

      def workflow_service
        @workflow_service ||= WorkflowClientFactory.build
      end
    end
  end
end
