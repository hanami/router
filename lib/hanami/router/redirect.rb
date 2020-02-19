# frozen_string_literal: true

module Hanami
  class Router
    # HTTP Redirect
    #
    # @since x.x.x
    # @api private
    class Redirect
      # @since x.x.x
      # @api private
      attr_reader :destination

      # @since x.x.x
      # @api private
      def initialize(destination, endpoint)
        @destination = destination
        @endpoint = endpoint
      end

      # @since x.x.x
      # @api private
      def call(env)
        @endpoint.call(env)
      end
    end
  end
end
