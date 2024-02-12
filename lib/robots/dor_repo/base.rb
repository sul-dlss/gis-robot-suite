# frozen_string_literal: true

module Robots
  module DorRepo
    class Base < LyberCore::Robot
      def retries_handler(msg)
        proc do |exception, attempt_number, _total_delay|
          logger.warn("#{msg}: try #{attempt_number} failed: #{exception.message}")
        end
      end
    end
  end
end
