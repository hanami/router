# frozen_string_literal: true

require "hanami/router/redirect"
require "hanami/router/block"

module Hanami
  class Router
    # Routes inspector
    #
    # @api private
    # @since 2.0.0
    class Inspector
      # @param routes [Array<Hash>] serialized routes
      #
      # @api private
      # @since 2.0.0
      def initialize(routes)
        @routes = inspect_routes(routes)
        freeze
      end

      # @return [String] The inspected routes
      #
      # @api private
      # @since 2.0.0
      def call
        @routes
      end

      private

      # @api private
      # @since 2.0.0
      def inspect_routes(routes)
        routes.map do |route|
          inspect_route(route)
        end.join("\n")
      end

      # @api private
      # @since 2.0.0
      def inspect_route(route)
        return "" if route.fetch(:http_method) == "HEAD"

        result = route.fetch(:http_method).to_s.ljust(8)
        result += route.fetch(:path).ljust(30)
        result += inspect_to(route.fetch(:to)).ljust(30)
        result += "as #{route.fetch(:as).inspect}".ljust(20) if route.fetch(:as, nil)

        unless route.fetch(:constraints, {}).empty?
          result += "(#{inspect_constraints(route.fetch(:constraints))})".ljust(40)
        end

        result
      end

      # @api private
      # @since 2.0.0
      def inspect_to(to)
        case to
        when String
          to
        when Proc
          "(proc)"
        when Class
          to.name || "(class)"
        when Block
          "(block)"
        when Redirect
          "#{to.destination} (HTTP #{to.code})"
        else
          inspect_to(to.class)
        end
      end

      # @api private
      # @since 2.0.0
      def inspect_constraints(constraints)
        constraints.map do |key, value|
          "#{key}: #{value.inspect}"
        end.join(", ")
      end
    end
  end
end
