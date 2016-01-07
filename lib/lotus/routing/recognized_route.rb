require 'lotus/utils/string'

module Lotus
  module Routing
    # Represents a result of router path recognition.
    #
    # @since 0.5.0
    #
    # @see Lotus::Router#recognize
    class RecognizedRoute
      # @since 0.5.0
      # @api private
      REQUEST_METHOD = 'REQUEST_METHOD'.freeze

      # @since 0.5.0
      # @api private
      NAMESPACE             = '%s::'.freeze

      # @since 0.5.0
      # @api private
      NAMESPACE_REPLACEMENT = ''.freeze

      # @since 0.5.0
      # @api private
      ACTION_PATH_SEPARATOR = '/'.freeze

      # @since 0.5.0
      # @api public
      attr_reader :params

      # Creates a new instance
      #
      # @param response [HttpRouter::Response] raw response of recognition
      # @param env [Hash] Rack env
      # @param router [Lotus::Routing::HttpRouter] low level router
      #
      # @return [Lotus::Routing::RecognizedRoute]
      #
      # @since 0.5.0
      # @api private
      def initialize(response, env, router)
        @env = env

        unless response.nil?
          @endpoint = response.route.dest
          @params   = response.params
        end

        @namespace        = router.namespace
        @action_separator = router.action_separator
      end

      # Rack protocol compatibility
      #
      # @param env [Hash] Rack env
      #
      # @return [Array] serialized Rack response
      #
      # @raise [Lotus::Router::NotRoutableEndpointError] if not routable
      #
      # @since 0.5.0
      # @api public
      #
      # @see Lotus::Routing::RecognizedRoute#routable?
      # @see Lotus::Router::NotRoutableEndpointError
      def call(env)
        if routable?
          @endpoint.call(env)
        else
          raise Lotus::Router::NotRoutableEndpointError.new(@env)
        end
      end

      # HTTP verb (aka method)
      #
      # @return [String]
      #
      # @since 0.5.0
      # @api public
      def verb
        @env[REQUEST_METHOD]
      end

      # Action name
      #
      # @return [String]
      #
      # @since 0.5.0
      # @api public
      #
      # @see Lotus::Router#recognize
      #
      # @example
      #   require 'lotus/router'
      #
      #   router = Lotus::Router.new do
      #     get '/books/:id', to: 'books#show'
      #   end
      #
      #   puts router.recognize('/books/23').action # => "books#show"
      def action
        namespace = NAMESPACE % @namespace

        if destination.match(namespace)
          Lotus::Utils::String.new(
            destination.sub(namespace, NAMESPACE_REPLACEMENT)
          ).underscore.rsub(ACTION_PATH_SEPARATOR, @action_separator)
        else
          destination
        end
      end

      # Check if routable
      #
      # @return [TrueClass,FalseClass]
      #
      # @since 0.5.0
      # @api public
      #
      # @see Lotus::Router#recognize
      #
      # @example
      #   require 'lotus/router'
      #
      #   router = Lotus::Router.new do
      #     get '/', to: 'home#index'
      #   end
      #
      #   puts router.recognize('/').routable?    # => true
      #   puts router.recognize('/foo').routable? # => false
      def routable?
        !!@endpoint
      end

      private

      # @since 0.5.0
      # @api private
      #
      # @see Lotus::Routing::Endpoint
      def destination
        @destination ||= begin
          case k = @endpoint.__getobj__
          when Class
            k
          else
            k.class
          end.name
        end
      end
    end
  end
end
