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
        route_rows = @routes.map do |route|
          route_to_row(route)
        end.reject(&:nil?)

        pretty_print(route_rows)
      end

      # @api private
      # @since 2.0.0
      NEW_LINE = $/
      private_constant :NEW_LINE

      # @api private
      # @since 2.0.0
      ROUTE_COLUMN_SEPARATOR = "  "
      private_constant :ROUTE_COLUMN_SEPARATOR

      # @api private
      # @since 2.0.0
      ROUTE_CONSTRAINT_SEPARATOR = ", "
      private_constant :ROUTE_CONSTRAINT_SEPARATOR

      # @api private
      # @since 2.0.0
      EMPTY_STRING = ""
      private_constant :EMPTY_STRING

      # @api private
      # @since 2.0.0
      def route_to_row(route)
        return nil if route.http_method == "HEAD"

        [
          route.http_method,
          route.path,
          inspect_to(route.to),
          route.as ? "as #{route.as.inspect}" : EMPTY_STRING,
          route.constraints.empty? ? EMPTY_STRING : "(#{inspect_constraints(route.constraints)})"
        ]
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

      # @api private
      # @since 2.0.0
      def get_column_widths(route_rows)
        column_count = route_rows.first.length

        Array.new(column_count) do |column_no|
          route_rows.map { |row| row[column_no].length }.max
        end
      end

      # @api private
      # @since 2.0.0
      def pretty_print(route_rows)
        return EMPTY_STRING if route_rows.empty?

        column_widths = get_column_widths(route_rows)

        route_rows.map do |row|
          row.each_with_index.map do |col, index|
            col.ljust(column_widths[index])
          end.join(ROUTE_COLUMN_SEPARATOR).rstrip
        end.join(NEW_LINE)
      end
    end
  end
end
