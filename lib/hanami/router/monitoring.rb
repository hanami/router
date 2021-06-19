# frozen_string_literal: true

require "dry/events/publisher"

module Hanami
  class Router
    # Router monitoring
    #
    # @api private
    # @since 2.0.0
    class Monitoring
      # @api private
      # @since 2.0.0
      PREFIX = "hanami.monitoring.router"

      # @api private
      # @since 2.0.0
      KEY = "#{PREFIX}.lookup"

      include Dry::Events::Publisher[PREFIX]
      register_event(KEY)

      # @api private
      # @since 2.0.0
      def call
        starting = now
        result = yield

        publish(KEY, elapsed: now - starting)
        result
      end

      private

      # @api private
      # @since 2.0.0
      def now
        Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond)
      end
    end
  end
end
