# frozen_string_literal: true

require "hanami/router/formatter/human_friendly"

module Hanami
  class Router
    # Routes inspector
    #
    # Builds a representation of an array of routes according to a given
    # formatter.
    #
    # @since 2.0.0
    class Inspector
      # @param routes [Array<Hanami::Route>]
      # @param formatter [#call] Takes the routes as an argument and returns
      #   whatever representation it creates. Defaults to
      #   {Hanami::Router::Formatter::HumanFriendly}.
      # @since 2.0.0
      def initialize(routes: [], formatter: Formatter::HumanFriendly.new)
        @routes = routes
        @formatter = formatter
      end

      # @param route [Hash] serialized route
      #
      # @api private
      # @since 2.0.0
      def add_route(route)
        @routes.push(route)
      end

      # @return [Any] Formatted routes
      #
      # @since 2.0.0
      def call(...)
        @formatter.call(@routes, ...)
      end
    end
  end
end
