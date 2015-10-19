require 'http_router'
require 'lotus/utils/io'
require 'lotus/routing/endpoint_resolver'
require 'lotus/routing/route'
require 'lotus/routing/parsers'
require 'lotus/routing/force_ssl'
require 'lotus/utils/path_prefix'

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
    class InvalidRouteException < ::StandardError
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
      # Script name - rack enviroment variable
      #
      # @since x.x.x
      # @api private
      SCRIPT_NAME = 'SCRIPT_NAME'.freeze

      # Initialize the router.
      #
      # @see Lotus::Router#initialize
      #
      # @since 0.1.0
      # @api private
      def initialize(options = {}, &blk)
        super(options, &nil)

        @default_scheme   = options[:scheme]   if options[:scheme]
        @default_host     = options[:host]     if options[:host]
        @default_port     = options[:port]     if options[:port]
        @route_class      = options[:route]    || Routing::Route
        @resolver         = options[:resolver] || Routing::EndpointResolver.new(options)
        @parsers          = Routing::Parsers.new(options[:parsers])
        @prefix           = Utils::PathPrefix.new(options[:prefix] || '')
        @force_ssl        = Lotus::Routing::ForceSsl.new(!!options[:force_ssl], host: @default_host, port: @default_port)
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
      def raw_path(route, *args)
        _rescue_url_recognition do
          _custom_path(super(route, *args))
        end
      end

      # Generate an absolute URL for a specified named route.
      #
      # @see Lotus::Router#path
      #
      # @since 0.1.0
      # @api private
      def raw_url(route, *args)
        _rescue_url_recognition do
          _custom_path(super(route, *args))
        end
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

      # Allow to mount a Rack app
      #
      # @see Lotus::Router#mount
      #
      # @since 0.1.1
      # @api private
      def mount(app, options)
        add("#{ options.fetch(:at) }*").to(
          @resolver.resolve(to: app)
        )
      end

      # @api private
      def raw_call(env, &blk)
        if response = @force_ssl.call(env)
          response
        else
          super(@parsers.call(env))
        end
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

      # @api private
      # @since x.x.x
      def rewrite_path_info(env, request)
        super
        env[SCRIPT_NAME] = @prefix + env[SCRIPT_NAME]
      end

      private

      def _rescue_url_recognition
        yield
      rescue ::HttpRouter::InvalidRouteException,
             ::HttpRouter::TooManyParametersException => e
        raise Routing::InvalidRouteException.new("#{ e.message } - please check given arguments")
      end

      def add_with_request_method(path, method, opts = {}, &app)
        super.generate(@resolver, opts, &app)
      end

      def _custom_path(uri_string)
        uri = URI.parse(uri_string)
        uri.path = @prefix.join(uri.path)
        uri.to_s
      end
    end
  end
end
