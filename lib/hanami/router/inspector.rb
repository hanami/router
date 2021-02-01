# frozen_string_literal: true

module Hanami
  class Router
    # Routes inspector
    #
    # @api private
    # @since 2.0.0
    class Inspector
      # @api private
      # @since 2.0.0
      def initialize(routes: [])
        @routes = routes
      end

      # @param route [Hash] serialized route
      #
      # @api private
      # @since 2.0.0
      def add_route(route)
        @routes.push(route)
      end

      # @param routes [Array<Hash>] serialized routes
      #
      # @return [String] The inspected routes
      #
      # @api private
      # @since 2.0.0
      def call(*)
        @routes.map(&:to_inspect).join(NEW_LINE)
      end

      # @api private
      # @since 2.0.0
      NEW_LINE = $/
      private_constant :NEW_LINE
    end
  end
end
