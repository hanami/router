# frozen_string_literal: true

require "hanami/router/redirect"
require "hanami/router/block"

module Hanami
  class Router
    class Route
      # @api private
      # @since 2.0.0
      attr_reader :http_method

      # @api private
      # @since 2.0.0
      attr_reader :path

      # @api private
      # @since 2.0.0
      attr_reader :to

      # @api private
      # @since 2.0.0
      attr_reader :as

      # @api private
      # @since 2.0.0
      attr_reader :constraints

      # @api private
      # @since 2.0.0
      def initialize(http_method:, path:, to:, as: nil, constraints: {}, blk: nil) # rubocop:disable Metrics/ParameterLists
        @http_method = http_method
        @path = path
        @to = to
        @as = as
        @constraints = constraints
        @blk = blk
        freeze
      end

      # @api private
      # @since 2.0.0
      def to_inspect
        return EMPTY_ROUTE if head?

        result = http_method.to_s.ljust(SMALL_STRING_JUSTIFY_AMOUNT)
        result += path.ljust(LARGE_STRING_JUSTIFY_AMOUNT)
        result += inspect_to(to).ljust(LARGE_STRING_JUSTIFY_AMOUNT)
        result += "as #{as.inspect}".ljust(MEDIUM_STRING_JUSTIFY_AMOUNT) if as

        if constraints?
          result += "(#{inspect_constraints(constraints)})".ljust(EXTRA_LARGE_STRING_JUSTIFY_AMOUNT)
        end

        result
      end

      private

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
      def head?
        http_method == "HEAD"
      end

      # @api private
      # @since 2.0.0
      def constraints?
        constraints.any?
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
