require 'uri'
require 'http_router'
require 'hanami/routing/endpoint_resolver'
require 'hanami/routing/route'
require 'hanami/routing/parsers'
require 'hanami/routing/force_ssl'
require 'hanami/routing/error'
require 'hanami/utils/path_prefix'
require 'hanami/http_router_monkey_patch'

module Hanami
  module Routing
    # Invalid route
    # This is raised when the router fails to recognize a route, because of the
    # given arguments.
    #
    # @since 0.1.0
    class InvalidRouteException < Hanami::Routing::Error
    end

    # HTTP router
    #
    # This implementation is based on ::HttpRouter (http_router gem).
    #
    # Hanami::Router wraps an instance of this class, in order to protect its
    # public API from any future change of ::HttpRouter.
    #
    # @since 0.1.0
    # @api private
    class HttpRouter < ::HttpRouter
      # Script name - rack environment variable
      #
      # @since 0.5.0
      # @api private
      SCRIPT_NAME = 'SCRIPT_NAME'.freeze

      # Path info - rack environment variable
      #
      # @since 0.7.0
      # @api private
      PATH_INFO = 'PATH_INFO'.freeze

      # Default PATH_INFO for Rack requests
      #
      # @since 0.7.0
      # @api private
      DEFAULT_PATH_INFO = '/'.freeze

      # URL separator
      #
      # @since 0.7.0
      # @api private
      URL_SEPARATOR = '/'.freeze

      # @since 0.5.0
      # @api private
      attr_reader :namespace

      # @since 0.8.0
      # @api private
      attr_reader :prefix

      # Initialize the router.
      #
      # @see Hanami::Router#initialize
      #
      # @since 0.1.0
      # @api private
      def initialize(options = {}, &blk)
        @compiled         = false
        @uri_parser       = URI::Parser.new
        super(options, &nil)

        @namespace        = options[:namespace] if options[:namespace]
        @default_scheme   = options[:scheme]    if options[:scheme]
        @default_host     = options[:host]      if options[:host]
        @default_port     = options[:port]      if options[:port]
        @route_class      = options[:route]    || Routing::Route
        @resolver         = options[:resolver] || Routing::EndpointResolver.new(options)
        @parsers          = Routing::Parsers.new(options[:parsers])
        @prefix           = Utils::PathPrefix.new(options[:prefix] || '')
        @force_ssl        = Hanami::Routing::ForceSsl.new(!!options[:force_ssl], host: @default_host, port: @default_port)
      end

      # Separator between controller and action name.
      #
      # @see Hanami::Routing::EndpointResolver::ACTION_SEPARATOR
      #
      # @since 0.1.0
      # @api private
      def action_separator
        @resolver.action_separator
      end

      # Finds a path from the given options.
      #
      # @see Hanami::Routing::EndpointResolver#find
      #
      # @since 0.1.0
      # @api private
      def find(options)
        @resolver.find(options)
      end

      # Generate a relative URL for a specified named route.
      #
      # @see Hanami::Router#path
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
      # @see Hanami::Router#path
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
      # @see Hanami::Router#options
      #
      # @since 0.1.0
      # @api private
      def options(path, options = {}, &blk)
        add_with_request_method(path, :options, options, &blk)
      end

      # Allow to mount a Rack app
      #
      # @see Hanami::Router#mount
      #
      # @since 0.1.1
      # @api private
      def mount(app, options)
        add("#{ options.fetch(:at) }*", host: options[:host]).to(
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
      def rewrite_partial_path_info(env, request)
        if request.path.empty?
          env[SCRIPT_NAME] += env[PATH_INFO]
          env[PATH_INFO]    = DEFAULT_PATH_INFO
        else
          path_info_before  = env[PATH_INFO].dup
          env[PATH_INFO]    = "/#{@uri_parser.escape(request.path.join(URL_SEPARATOR))}"
          env[SCRIPT_NAME] += path_info_before[0, path_info_before.bytesize - env[PATH_INFO].bytesize]
        end
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
