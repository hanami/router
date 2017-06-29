# frozen_string_literal: true

# Hanami
#
# @since 0.1.0
module Hanami
  # Hanami routing
  #
  # @since 0.1.0
  module Routing
    # @since 0.5.0
    class Error < ::StandardError
    end

    # Invalid route
    # This is raised when the router fails to recognize a route, because of the
    # given arguments.
    #
    # @since 0.1.0
    class InvalidRouteException < Error
    end

    # Endpoint not found
    # This is raised when the router fails to load an endpoint at the runtime.
    #
    # @since 0.1.0
    class EndpointNotFound < Error
    end

    # @since x.x.x
    class NotCallableEndpointError < Error
      def initialize(endpoint)
        super("#{endpoint.inspect} isn't compatible with Rack. Please make sure it implements #call.")
      end
    end

    require "hanami/routing/endpoint"
    require "hanami/routing/namespace"
    require "hanami/routing/resource"
    require "hanami/routing/resources"
    require "hanami/routing/force_ssl"
    require "hanami/routing/parsers"
    require "hanami/routing/recognized_route"
  end
end
