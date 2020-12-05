# frozen_string_literal: true

module Hanami
  class Router
    # HTTP Redirect
    #
    # @since 2.0.0
    # @api private
    class Redirect
      # @since 2.0.0
      # @api private
      attr_reader :destination

      # @since 2.0.0
      # @api private
      def initialize(destination, endpoint)
        @destination = destination
        @endpoint = endpoint
      end

      # @since 2.0.0
      # @api private
      def call(env)
        @endpoint.call(env)
      end
    end
  end
end
