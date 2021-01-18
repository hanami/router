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
      # @api private
      # @since 2.0.0
      def initialize
        freeze
      end

      # @param routes [Array<Hash>] serialized routes
      #
      # @return [String] The inspected routes
      #
      # @api private
      # @since 2.0.0
      def call(routes)
        routes.map do |route|
          inspect_route(route)
        end.join(NEW_LINE)
      end

      private

      # @api private
      # @since 2.0.0
      NEW_LINE = $/
      private_constant :NEW_LINE

      # @api private
      # @since 2.0.0
      EMPTY_ROUTE = ""
      private_constant :EMPTY_ROUTE

      # @api private
      # @since 2.0.0
      ROUTE_CONSTRAINT_SEPARATOR = ", "
      private_constant :ROUTE_CONSTRAINT_SEPARATOR

      # @api private
      # @since 2.0.0
      SMALL_STRING_JUSTIFY_AMOUNT = 8
      private_constant :SMALL_STRING_JUSTIFY_AMOUNT

      # @api private
      # @since 2.0.0
      MEDIUM_STRING_JUSTIFY_AMOUNT = 20
      private_constant :MEDIUM_STRING_JUSTIFY_AMOUNT

      # @api private
      # @since 2.0.0
      LARGE_STRING_JUSTIFY_AMOUNT = 30
      private_constant :LARGE_STRING_JUSTIFY_AMOUNT

      # @api private
      # @since 2.0.0
      EXTRA_LARGE_STRING_JUSTIFY_AMOUNT = 40
      private_constant :EXTRA_LARGE_STRING_JUSTIFY_AMOUNT

      # @api private
      # @since 2.0.0
      EXTRA_SEPERATOR = " "
      private_constant :EXTRA_SEPERATOR

      # @api private
      # @since 2.0.0
      def inspect_route(route)
        return EMPTY_ROUTE if route.fetch(:http_method) == "HEAD"

        result = route.fetch(:http_method).to_s.ljust(SMALL_STRING_JUSTIFY_AMOUNT)
        result += route.fetch(:path).ljust(LARGE_STRING_JUSTIFY_AMOUNT) + EXTRA_SEPERATOR
        result += inspect_to(route.fetch(:to)).ljust(LARGE_STRING_JUSTIFY_AMOUNT)
        result += "#{EXTRA_SEPERATOR}as #{route.fetch(:as).inspect}".ljust(MEDIUM_STRING_JUSTIFY_AMOUNT) if route[:as]

        unless route.fetch(:constraints, {}).empty?
          result += "#{EXTRA_SEPERATOR}(#{inspect_constraints(route.fetch(:constraints))})" \
            .ljust(EXTRA_LARGE_STRING_JUSTIFY_AMOUNT)
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
        end.join(ROUTE_CONSTRAINT_SEPARATOR)
      end
    end
  end
end
