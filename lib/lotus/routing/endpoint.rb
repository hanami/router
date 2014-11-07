require 'delegate'
require 'lotus/utils/class'

module Lotus
  module Routing
    # Endpoint not found
    # This is raised when the router fails to load an endpoint at the runtime.
    #
    # @since 0.1.0
    class EndpointNotFound < ::StandardError
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
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     get '/proc',     to: ->(env) { [200, {}, ['This will use Lotus::Routing::Endpoint']] }
    #     get '/rack-app', to: RackApp.new
    #   end
    class Endpoint < SimpleDelegator
      # @since x.x.x
      def inspect
        case __getobj__
        when Proc
          source, line     = __getobj__.source_location
          lambda_inspector = " (lambda)"  if  __getobj__.lambda?

          "#<Proc@#{ source }:#{ line }#{ lambda_inspector }>"
        when Class
          __getobj__
        else
          "#<#{ __getobj__.class }>"
        end
      end
    end

    # Routing endpoint
    # This is the object that responds to an HTTP request made against a certain
    # path.
    #
    # The router will use this class for:
    #
    #   * Classes
    #   * Lotus::Action endpoints referenced as a class
    #   * Lotus::Action endpoints referenced a string
    #   * RESTful resource(s)
    #
    # @since 0.1.0
    #
    # @api private
    #
    # @example
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     get '/class',               to: RackMiddleware
    #     get '/lotus-action-class',  to: DashboardController::Index
    #     get '/lotus-action-string', to: 'dashboard#index'
    #
    #     resource  'identity'
    #     resources 'articles'
    #   end
    class ClassEndpoint < Endpoint
      # Rack interface
      #
      # @since 0.1.0
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
    # @see Lotus::Routing::ClassEndpoint
    class LazyEndpoint < Endpoint
      # Initialize the lazy endpoint
      #
      # @since 0.1.0
      def initialize(name, namespace)
        @name, @namespace = name, namespace
      end

      # Rack interface
      #
      # @raise [EndpointNotFound] when the endpoint can't be found.
      #
      # @since 0.1.0
      def call(env)
        obj.call(env)
      end

      # @since x.x.x
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

      # @since x.x.x
      # @api private
      def klass
        Utils::Class.load!(@name, @namespace)
      rescue NameError => e
        raise EndpointNotFound.new(e.message)
      end
    end
  end
end
