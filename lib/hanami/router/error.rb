# frozen_string_literal: true

module Hanami
  class Router
    # Base error
    #
    # @since 0.5.0
    class Error < StandardError
    end

    # Missing endpoint error. It's raised when the route definition is missing `to:` endpoint and a block.
    #
    # @since 2.0.0
    class MissingEndpointError < Error
      def initialize(path)
        super("missing endpoint for #{path.inspect}")
      end
    end

    # Invalid route exception. It's raised when the router cannot recognize a route
    #
    # @since 2.0.0
    class InvalidRouteException < Error
      def initialize(name)
        super("No route could be generated for #{name.inspect} - please check given arguments")
      end
    end

    # Invalid route expansion exception. It's raised when the router recognizes
    # a route but given variables cannot be expanded into a path/url
    #
    # @since 2.0.0
    #
    # @see Hanami::Router#path
    # @see Hanami::Router#url
    class InvalidRouteExpansionException < Error
      def initialize(name, message)
        super("No route could be generated for `#{name.inspect}': #{message}")
      end
    end

    # Handle unknown HTTP status codes
    #
    # @since 2.0.0
    class UnknownHTTPStatusCodeError < Error
      def initialize(code)
        super("Unknown HTTP status code: #{code.inspect}")
      end
    end

    # This error is raised when <tt>#call</tt> is invoked on a non-routable
    # recognized route.
    #
    # @since 0.5.0
    #
    # @see Hanami::Router#recognize
    # @see Hanami::Router::RecognizedRoute
    # @see Hanami::Router::RecognizedRoute#call
    # @see Hanami::Router::RecognizedRoute#routable?
    class NotRoutableEndpointError < Error
      # @since 0.5.0
      def initialize(env)
        super %(Cannot find routable endpoint for: #{env['REQUEST_METHOD']} #{env['PATH_INFO']})
      end
    end
  end
end
