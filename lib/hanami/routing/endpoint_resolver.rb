# frozen_string_literal: true

require "hanami/utils/string"
require "hanami/utils/class"
require "hanami/routing/endpoint"

module Hanami
  module Routing
    # Resolve duck-typed endpoints
    #
    # @since 0.1.0
    #
    # @api private
    class EndpointResolver
      # @since x.x.x
      # @api private
      #
      # FIXME: Shall this be the default of Utils::Class.load! ?
      DEFAULT_NAMESPACE = Object

      # Controller / action separator for Hanami
      #
      # @since x.x.x
      # @api private
      #
      # @example
      #   require "hanami/router"
      #
      #   Hanami::Router.new do
      #     get "/home", to: "home#index"
      #   end
      ACTION_SEPARATOR = "#"

      # Replacement to load an action from the string name.
      #
      # Please note that the `"/"` value is required by `Hanami::Utils::String#classify`.
      #
      # Given the `"home#index"` string, with the `Web::Controllers` namespace,
      # it will try to load `Web::Controllers::Home::Index` action.
      #
      # @since x.x.x
      # @api private
      ACTION_SEPARATOR_REPLACEMENT = "/"

      def call(name, namespace = nil, configuration = nil)
        endpoint = case name
                   when String
                     find_string(name, namespace || DEFAULT_NAMESPACE, configuration)
                   when Class
                     name.respond_to?(:call) ? name : name.new
                   else
                     name
                   end

        raise NotCallableEndpointError.new(endpoint) unless endpoint.respond_to?(:call)
        endpoint
      end

      private

      # Find an endpoint from its name
      #
      # @param name [String] the endpoint name
      # @param namespace [Module] the Ruby module where to lookup the endpoint
      # @param configuration [Hanami::Controller::Configuration] the action
      #   configuration
      #
      # @return [Object, Hanami::Routing::Endpoint] a Rack compatible
      #   endpoint
      #
      # @since x.x.x
      # @api private
      #
      # @example Basic Usage
      #   Hanami::Routing::Endpoint.find("MyMiddleware")
      #     # => #<MyMiddleware:0x007ff6df06f468>
      #
      # @example Hanami Action
      #   Hanami::Routing::Endpoint.find("home#index", Web::Controllers)
      #     # => #<Web::Controllers::Home::Index:0x007ff6df06f468>
      def find_string(name, namespace, configuration)
        n     = Utils::String.new(name.sub(ACTION_SEPARATOR, ACTION_SEPARATOR_REPLACEMENT)).classify.to_s
        klass = Utils::Class.load!(n, namespace)

        if hanami_action?(name, n)
          klass.new(configuration: configuration)
        else
          klass.new
        end
      rescue NameError
        Hanami::Routing::LazyEndpoint.new(n, namespace)
      end

      # FIXME: could do with some documentation/comments, I really have no idea what it's doing
      def hanami_action?(name, endpoint)
        name != endpoint
      end
    end
  end
end
