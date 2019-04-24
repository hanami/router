# frozen_string_literal: true

module Hanami
  module Routing
    # Named routes
    #
    # @since 2.0.0
    # @api private
    class Named
      # @since 2.0.0
      # @api private
      def initialize
        @data = {}
      end

      # @since 2.0.0
      # @api private
      def set(name, route)
        @data[name] = route
      end

      # @since 2.0.0
      # @api private
      def get(name, args = {})
        @data.fetch(name).path(args)
      rescue KeyError
        raise Hanami::Routing::InvalidRouteException.new("No route could be generated for #{name.inspect} - please check given arguments")
      end
    end
  end
end
