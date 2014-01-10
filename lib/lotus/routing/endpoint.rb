require 'delegate'
require 'lotus/utils/class'

module Lotus
  module Routing
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
      # @since 0.1.0
      def call(env)
        obj.call(env)
      end

      private
      def obj
        Utils::Class.load!(@name, @namespace).new
      end
    end
  end
end
