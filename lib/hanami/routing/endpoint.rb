# frozen_string_literal: true

require "delegate"
require "hanami/utils/class"
require "hanami/utils/string"

module Hanami
  module Routing
    module Endpoint
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
      ACTION_SEPARATOR = "#".freeze

      # Replacement to load an action from the string name.
      #
      # Please note that the `"/"` value is required by `Hanami::Utils::String#classify`.
      #
      # Given the `"home#index"` string, with the `Web::Controllers` namespace,
      # it will try to load `Web::Controllers::Home::Index` action.
      #
      # @since x.x.x
      # @api private
      ACTION_SEPARATOR_REPLACEMENT = "/".freeze

      # Find an endpoint for the given name
      #
      # @param name [String,Class,Proc,Object] the endpoint expressed as name
      #   (`String`), as a Rack class application (`Class`), as a Rack
      #   compatible proc (`Proc`), or as any other Rack compatible object
      #   (`Object`)
      # @param namespace [Module] the Ruby module where to lookup the endpoint
      #
      # @raise [Hanami::Routing::NotCallableEndpointError] if the found object
      #   doesn't implement Rack protocol (`#call`)
      #
      # @return [Object, Hanami::Routing::LazyEndpoint] a Rack compatible
      #   endpoint
      #
      # @since x.x.x
      # @api private
      def self.find(name, namespace)
        endpoint = case name
        when String
          find_string(name, namespace || DEFAULT_NAMESPACE)
        when Class
          name.respond_to?(:call) ? name : name.new
        else
          name
        end

        raise NotCallableEndpointError.new(endpoint) unless endpoint.respond_to?(:call)
        endpoint
      end

      # @since 1.0.1
      # @api private
      def redirect?
        false
      end

      # @since 1.0.1
      # @api private
      def destination_path
      end

      # Find an endpoint from its name
      #
      # @param name [String] the endpoint name
      # @param namespace [Module] the Ruby module where to lookup the endpoint
      #
      # @return [Object, Hanami::Routing::LazyEndpoint] a Rack compatible
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
      def self.find_string(name, namespace)
        n     = Utils::String.new(name.sub(ACTION_SEPARATOR, ACTION_SEPARATOR_REPLACEMENT)).classify.to_s
        klass = Utils::Class.load!(n, namespace)
        klass.new
      rescue NameError
        Hanami::Routing::LazyEndpoint.new(n, namespace)
      end

      private_class_method :find_string
    end

    # Routing endpoint
    # This is the object that responds to an HTTP request made against a certain
    # path.
    #
    # The router will use this class for the same use cases of `ClassEndpoint`,
    # but when the target class can't be found, instead of raise a `LoadError`
    # we reference in a lazy endpoint.
    #
    # For each incoming HTTP request, it will look for the referenced class,
    # then it will instantiate and invoke #call on the object.
    #
    # This behavior is required to solve a chicken-egg situation when we try
    # to load the router first and then the application with all its endpoints.
    #
    # @since 0.1.0
    #
    # @api private
    #
    # @see Hanami::Routing::ClassEndpoint
    class LazyEndpoint < SimpleDelegator
      # Initialize the lazy endpoint
      #
      # @since 0.1.0
      # @api private
      def initialize(name, namespace)
        @name      = name
        @namespace = namespace
      end

      # Rack interface
      #
      # @raise [EndpointNotFound] when the endpoint can't be found.
      #
      # @since 0.1.0
      # @api private
      def call(env)
        obj.call(env)
      end

      # @since 0.2.0
      # @api private
      def inspect
        # TODO review this implementation once the namespace feature will be
        # cleaned up.
        result = klass rescue nil

        if result.nil?
          result = @name
          result = "#{@namespace}::#{result}" if @namespace != Object
        end

        result
      end

      # @since 1.0.0
      # @api private
      def routable?
        !__getobj__.nil?
      rescue ArgumentError
        false
      end

      private

      # @since 0.1.0
      # @api private
      def obj
        klass.new
      end

      # @since 0.2.0
      # @api private
      def klass
        Utils::Class.load!(@name, @namespace)
      rescue NameError => e
        raise EndpointNotFound.new(e.message)
      end
    end
  end
end
