# frozen_string_literal: true

module Hanami
  class Router
    # Base error
    #
    # @since x.x.x
    class Error < StandardError
    end

    # Invalid route exception. It's raised when the router cannot recognize a route
    #
    # @since x.x.x
    class InvalidRouteException < Error
      def initialize(name)
        super("No route could be generated for #{name.inspect} - please check given arguments")
      end
    end

    # Invalid route expansion exception. It's raised when the router recognizes
    # a route but given variables cannot be expanded into a path/url
    #
    # @since x.x.x
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
    # @since x.x.x
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
