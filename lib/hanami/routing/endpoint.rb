require 'delegate'
require 'hanami/routing/error'
require 'hanami/utils/class'

module Hanami
  module Routing
    # Endpoint not found
    # This is raised when the router fails to load an endpoint at the runtime.
    #
    # @since 0.1.0
    class EndpointNotFound < Hanami::Routing::Error
    end

    # Routing endpoint
    # This is the object that responds to an HTTP request made against a certain
    # path.
    #
    # The router will use this class for:
    #
    #   * Procs and any Rack compatible object (respond to #call)
    #
    # @since 0.1.0
    #
    # @api private
    #
    # @example
    #   require 'hanami/router'
    #
    #   Hanami::Router.new do
    #     get '/proc',     to: ->(env) { [200, {}, ['This will use Hanami::Routing::Endpoint']] }
    #     get '/rack-app', to: RackApp.new
    #   end
    class Endpoint < SimpleDelegator
      # @since 0.2.0
      # @api private
      def inspect
        case __getobj__
        when Proc
          source, line     = __getobj__.source_location
          lambda_inspector = " (lambda)"  if  __getobj__.lambda?

          "#<Proc@#{ ::File.expand_path(source) }:#{ line }#{ lambda_inspector }>"
        when Class
          __getobj__
        else
          "#<#{ __getobj__.class }>"
        end
      end

      # @since 1.0.0
      # @api private
      def routable?
        !__getobj__.nil?
      rescue ArgumentError
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
    end

    # Routing endpoint
    # This is the object that responds to an HTTP request made against a certain
    # path.
    #
    # The router will use this class for:
    #
    #   * Classes
    #   * Hanami::Action endpoints referenced as a class
    #   * Hanami::Action endpoints referenced a string
    #   * RESTful resource(s)
    #
    # @since 0.1.0
    #
    # @api private
    #
    # @example
    #   require 'hanami/router'
    #
    #   Hanami::Router.new do
    #     get '/class',               to: RackMiddleware
    #     get '/hanami-action-class',  to: Dashboard::Index
    #     get '/hanami-action-string', to: 'dashboard#index'
    #
    #     resource  'identity'
    #     resources 'articles'
    #   end
    class ClassEndpoint < Endpoint
      # Rack interface
      #
      # @since 0.1.0
      # @api private
      def call(env)
        __getobj__.new.call(env)
      end
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
    class LazyEndpoint < Endpoint
      # Initialize the lazy endpoint
      #
      # @since 0.1.0
      # @api private
      def initialize(name, namespace)
        @name, @namespace = name, namespace
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
          result = "#{ @namespace }::#{ result }" if @namespace != Object
        end

        result
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

    # @since 1.0.1
    # @api private
    class RedirectEndpoint < Endpoint
      # @since 1.0.1
      # @api private
      attr_reader :destination_path

      # @since 1.0.1
      # @api private
      def initialize(destination_path, destination)
        @destination_path = destination_path
        super(destination)
      end

      # @since 1.0.1
      # @api private
      def redirect?
        true
      end
    end
  end
end
