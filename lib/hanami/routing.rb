# frozen_string_literal: true

require "uri"
require "rack/utils"
require "mustermann/rails"

# Hanami
#
# @since 0.1.0
module Hanami
  # Hanami routing
  #
  # @since 0.1.0
  module Routing
    PATH_INFO      = "PATH_INFO"
    QUERY_STRING   = "QUERY_STRING"
    REQUEST_METHOD = "REQUEST_METHOD"

    HTTP_VERBS = %w[get post delete put patch trace options].freeze

    PARAMS = "router.params"

    def self.http_verbs
      HTTP_VERBS
    end

    # @since 0.5.0
    class Error < ::StandardError
    end

    # Invalid route
    # This is raised when the router fails to recognize a route, because of the
    # given arguments.
    #
    # @since 0.1.0
    class InvalidRouteException < Error
    end

    # Endpoint not found
    # This is raised when the router fails to load an endpoint at the runtime.
    #
    # @since 0.1.0
    class EndpointNotFound < Error
    end

    # @since x.x.x
    class NotCallableEndpointError < Error
      def initialize(endpoint)
        super("#{endpoint.inspect} isn't compatible with Rack. Please make sure it implements #call.")
      end
    end

    # HTTP redirect
    #
    # @since x.x.x
    # @api private
    class Redirect
      # @since x.x.x
      # @api private
      LOCATION = "Location"

      # @since x.x.x
      # @api private
      STATUS_RANGE = (300..399).freeze

      attr_reader :path
      alias destination_path path

      # Instantiate a new redirect
      #
      # @param path [String] a relative or absolute URI
      # @param status [Integer] a redirect status (an integer between `300` and `399`)
      #
      # @return [Hanami::Routing::Redirect] a new instance
      #
      # @raise [ArgumentError] if path is nil, or status code isn't a redirect
      #
      # @since x.x.x
      # @api private
      def initialize(path, status)
        raise ArgumentError.new("Path is nil") if path.nil?
        raise ArgumentError.new("Status code isn't a redirect: #{status.inspect}") unless STATUS_RANGE.include?(status)

        @path   = path
        @status = status
        freeze
      end

      def call(_)
        [@status, { LOCATION => @path }, []]
      end

      def redirect?
        true
      end
    end

    # Route
    #
    # @since 0.1.0
    # @api private
    class Route
      # @since 0.7.0
      # @api private
      def initialize(verb, path, endpoint, constraints)
        @verb     = verb
        @path     = Mustermann.new(path, type: :rails, version: "5.0", capture: constraints)
        @endpoint = endpoint
        freeze
      end

      # @since 0.1.0
      # @api private
      def call(env)
        env[PARAMS] ||= {}
        env[PARAMS].merge!(Rack::Utils.parse_nested_query(env[QUERY_STRING]))
        env[PARAMS].merge!(@path.params(env[PATH_INFO]))
        env[PARAMS] = Utils::Hash.deep_symbolize(env[PARAMS])

        @endpoint.call(env)
      end

      # @since 0.1.0
      # @api private
      def path(args)
        @path.expand(:append, args)
      rescue Mustermann::ExpandError => e
        raise Hanami::Routing::InvalidRouteException.new(e.message)
      end

      # @since x.x.x
      # @api private
      def match?(env)
        match_path?(env) &&
          @verb.include?(env[REQUEST_METHOD])
      end

      # @since x.x.x
      # @api private
      def match_path?(env)
        @path =~ env[PATH_INFO]
      end
    end

    # @since x.x.x
    # @api private
    module Uri
      # @since x.x.x
      # @api private
      HTTP  = "http"

      # @since x.x.x
      # @api private
      HTTPS = "https"

      # @since x.x.x
      # @api private
      DEFAULT_SCHEME = HTTP

      # Build a URI string from the given arguments
      #
      # @param scheme [String] the URI scheme: one of `"http"` or `"https"`
      # @param host [String] the URI host
      # @param port [String,Integer] the URI port
      #
      # @raise [ArgumentError] if one of `scheme`, `host`, `port` is `nil`, or
      #   if `scheme` is unknown
      #
      # @since x.x.x
      # @api private
      def self.build(scheme:, host:, port:)
        raise ArgumentError.new("host is nil") if host.nil?
        raise ArgumentError.new("port is nil") if port.nil?

        case scheme
        when HTTP
          URI::HTTP
        when HTTPS
          URI::HTTPS
        else
          raise ArgumentError.new("Unknown scheme: #{scheme.inspect}")
        end.build(scheme: scheme, host: host, port: port).to_s
      end
    end

    require "hanami/routing/endpoint"
    require "hanami/routing/prefix"
    require "hanami/routing/scope"
    require "hanami/routing/resource"
    require "hanami/routing/resources"
    require "hanami/routing/force_ssl"
    require "hanami/routing/parsers"
    require "hanami/routing/recognized_route"
  end
end
