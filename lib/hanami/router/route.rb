# frozen_string_literal: true

require "hanami/router/redirect"
require "hanami/router/block"

module Hanami
  class Router
    # A route from the router
    #
    # @since 2.0.0
    class Route
      # @api private
      # @since 2.0.0
      ROUTE_CONSTRAINT_SEPARATOR = ", "
      private_constant :ROUTE_CONSTRAINT_SEPARATOR

      # @since 2.0.0
      attr_reader :http_method

      # @since 2.0.0
      attr_reader :path

      # @since 2.0.0
      attr_reader :to

      # @since 2.0.0
      attr_reader :as

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

      # @since 2.0.0
      def head?
        http_method == ::Rack::HEAD
      end

      # @since 2.0.0
      def as?
        !as.nil?
      end

      # @since 2.0.0
      def constraints?
        constraints.any?
      end

      # @since 2.0.0
      def inspect_to(value = to)
        case value
        when String
          value
        when Proc
          "(proc)"
        when Class
          value.name || "(class)"
        when Block
          "(block)"
        when Redirect
          "#{value.destination} (HTTP #{to.code})"
        else
          inspect_to(value.class)
        end
      end

      # @since 2.0.0
      def inspect_constraints
        @constraints.map do |key, value|
          "#{key}: #{value.inspect}"
        end.join(ROUTE_CONSTRAINT_SEPARATOR)
      end

      # @since 2.0.0
      def inspect_as
        as ? as.inspect : Router::EMPTY_STRING
      end
    end
  end
end
