# frozen_string_literal: true

module Hanami
  class Router
    # Represents a result of router path recognition.
    #
    # @since 0.5.0
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
        if routable?
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
        @env[REQUEST_METHOD]
      end

      # Relative URL (path)
      #
      # @return [String]
      #
      # @since 0.7.0
      # @api public
      def path
        @env[PATH_INFO]
      end

      # @since 0.7.0
      # @api public
      def params
        @env[PARAMS]
      end

      # @since 0.7.0
      # @api public
      def endpoint
        return nil if redirect?

        @endpoint
      end

      # @since 0.7.0
      # @api public
      def routable?
        !@endpoint.nil?
      end

      # @since 0.7.0
      # @api public
      def redirect?
        @endpoint.is_a?(Redirect)
      end

      # @since 0.7.0
      # @api public
      def redirection_path
        return nil unless redirect?

        @endpoint.destination
      end
    end
  end
end
