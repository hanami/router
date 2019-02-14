# frozen_string_literal: true

require "delegate"
require "hanami/utils/class"

module Hanami
  module Routing
    # Routing endpoint
    #
    # @since 2.0.0
    # @api private
    module Endpoint
      # Controller / action separator for Hanami
      #
      # @since 2.0.0
      # @api private
      #
      # @example
      #   require "hanami/router"
      #
      #   Hanami::Router.new do
      #     get "/home", to: "home#index"
      #   end
      ACTION_SEPARATOR = "#"

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
        # TODO: review this implementation once the namespace feature will be
        # cleaned up.
        result = begin
                   klass
                 rescue
                   nil
                 end

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
