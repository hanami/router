# frozen_string_literal: true

module Hanami
  class Router
    # Represents a result of router path recognition.
    #
    # @since x.x.x
    #
    # @see Hanami::Router#recognize
    class RecognizedRoute
      def initialize(endpoint, env)
        @endpoint = endpoint
        @env = env
      end

      # Rack protocol compatibility
      #
      # @param env [Hash] Rack env
      #
      # @return [Array] serialized Rack response
      #
      # @raise [Hanami::Router::NotRoutableEndpointError] if not routable
      #
      # @since 0.5.0
      # @api public
      #
      # @see Hanami::Router::RecognizedRoute#routable?
      # @see Hanami::Router::NotRoutableEndpointError
      def call(env)
        if routable? # rubocop:disable Style/GuardClause
          @endpoint.call(env)
        else
          raise NotRoutableEndpointError.new(@env)
        end
      end

      # HTTP verb (aka method)
      #
      # @return [String]
      #
      # @since 0.5.0
      # @api public
      def verb
        @env["REQUEST_METHOD"]
      end

      # Relative URL (path)
      #
      # @return [String]
      #
      # @since 0.7.0
      # @api public
      def path
        @env["PATH_INFO"]
      end

      def params
        @env["router.params"]
      end

      def endpoint
        return nil if redirect?

        @endpoint
      end

      def routable?
        !@endpoint.nil?
      end

      def redirect?
        @endpoint.is_a?(Redirect)
      end

      def redirection_path
        return nil unless redirect?

        @endpoint.destination
      end
    end
  end
end
