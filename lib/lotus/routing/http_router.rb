require 'http_router'
require 'lotus/utils/io'
require 'lotus/routing/endpoint_resolver'
require 'lotus/routing/route'

Lotus::Utils::IO.silence_warnings do
  HttpRouter::Route::VALID_HTTP_VERBS = %w{GET POST PUT PATCH DELETE HEAD OPTIONS TRACE}
end

module Lotus
  module Routing
    # Invalid route
    # This is raised when the router fails to recognize a route, because of the
    # given arguments.
    #
    # @since 0.1.0
    class InvalidRouteException < ::Exception
    end

    # HTTP router
    #
    # This implementation is based on ::HttpRouter (http_router gem).
    #
    # Lotus::Router wraps an instance of this class, in order to protect its
    # public API from any future change of ::HttpRouter.
    #
    # @since 0.1.0
    # @api private
    class HttpRouter < ::HttpRouter
      # Initialize the router.
      #
      # @see Lotus::Router#initialize
      #
      # @since 0.1.0
      # @api private
      def initialize(options = {}, &blk)
        super(options, &nil)

        @default_scheme = options[:scheme]   if options[:scheme]
        @default_host   = options[:host]     if options[:host]
        @default_port   = options[:port]     if options[:port]
        @route_class    = options[:route]    || Routing::Route
        @resolver       = options[:resolver] || Routing::EndpointResolver.new(options)
      end

      # Separator between controller and action name.
      #
      # @see Lotus::Routing::EndpointResolver::ACTION_SEPARATOR
      #
      # @since 0.1.0
      # @api private
      def action_separator
        @resolver.action_separator
      end

      # Finds a path from the given options.
      #
      # @see Lotus::Routing::EndpointResolver#find
      #
      # @since 0.1.0
      # @api private
      def find(options)
        @resolver.find(options)
      end

      # Generate a relative URL for a specified named route.
      #
      # @see Lotus::Router#path
      #
      # @since 0.1.0
      # @api private
      def path(route, *args)
        _rescue_url_recognition { super }
      end

      # Generate an absolute URL for a specified named route.
      #
      # @see Lotus::Router#path
      #
      # @since 0.1.0
      # @api private
      def url(route, *args)
        _rescue_url_recognition { super }
      end

      # Support for OPTIONS HTTP verb
      #
      # @see Lotus::Router#options
      #
      # @since 0.1.0
      # @api private
      def options(path, options = {}, &blk)
        add_with_request_method(path, :options, options, &blk)
      end

      # @api private
      def reset!
        uncompile
        @routes, @named_routes, @root = [], Hash.new{|h,k| h[k] = []}, Node::Root.new(self)
        @default_host, @default_port, @default_scheme = 'localhost', 80, 'http'
      end

      # @api private
      def pass_on_response(response)
        super response.to_a
      end

      # @api private
      def no_response(request, env)
        if request.acceptable_methods.any? && !request.acceptable_methods.include?(env['REQUEST_METHOD'])
          [405, {'Allow' => request.acceptable_methods.sort.join(", ")}, []]
        else
          @default_app.call(env)
        end
      end

      private
      def add_with_request_method(path, method, opts = {}, &app)
        super.generate(@resolver, opts, &app)
      end

      def _rescue_url_recognition
        yield
      rescue ::HttpRouter::InvalidRouteException,
             ::HttpRouter::TooManyParametersException => e
        raise Routing::InvalidRouteException.new(e.message)
      end
    end
  end
end
