require 'rack/request'

module Lotus
  module Routing
    # Force ssl
    #
    # Redirect response to the secure equivalent resource (https)
    #
    # @since x.x.x
    # @api private
    class ForceSsl
      # Https scheme
      #
      # @since x.x.x
      # @api private
      SSL_SCHEME = 'https'.freeze

      # @since x.x.x
      # @api private
      HTTPS = 'HTTPS'.freeze

      # @since x.x.x
      # @api private
      ON    = 'on'.freeze

      # Location header
      #
      # @since x.x.x
      # @api private
      LOCATION_HEADER = 'Location'.freeze

      # Default http port
      #
      # @since x.x.x
      # @api private
      DEFAULT_HTTP_PORT = 80

      # Default ssl port
      #
      # @since x.x.x
      # @api private
      DEFAULT_SSL_PORT = 443

      # Moved Permanently http code
      #
      # @since x.x.x
      # @api private
      MOVED_PERMANENTLY_HTTP_CODE = 301

      # Temporary Redirect http code
      #
      # @since x.x.x
      # @api private
      TEMPORARY_REDIRECT_HTTP_CODE = 307

      # @since x.x.x
      # @api private
      HTTP_X_FORWARDED_SSL = 'HTTP_X_FORWARDED_SSL'.freeze

      # @since x.x.x
      # @api private
      HTTP_X_FORWARDED_SCHEME = 'HTTP_X_FORWARDED_SCHEME'.freeze

      # @since x.x.x
      # @api private
      HTTP_X_FORWARDED_PROTO = 'HTTP_X_FORWARDED_PROTO'.freeze

      # @since x.x.x
      # @api private
      HTTP_X_FORWARDED_PROTO_SEPARATOR = ','.freeze

      # @since x.x.x
      # @api private
      RACK_URL_SCHEME = 'rack.url_scheme'.freeze

      # @since x.x.x
      # @api private
      REQUEST_METHOD = 'REQUEST_METHOD'.freeze

      # @since x.x.x
      # @api private
      IDEMPOTENT_METHODS = ['GET', 'HEAD'].freeze

      EMPTY_BODY = ''.freeze

      # Initialize ForceSsl.
      #
      # @param force [Boolean] activate redirection to SSL
      # @param options [Hash] set of options
      # @option options [String] :host
      # @option options [Integer] :port
      #
      # @since x.x.x
      # @api private
      def initialize(active, options = {})
        @active = active
        @host   = options[:host]
        @port   = options[:port]

        _redefine_call
      end

      # Set 301 status and Location header if this feature is activated.
      #
      # @param env [Hash] a Rack env instance
      #
      # @return [Array]
      #
      # @see Lotus::Routing::HttpRouter#call
      #
      # @since x.x.x
      # @api private
      def call(env)
      end

      # Check if router has to force the response with ssl
      #
      # @return [Boolean]
      #
      # @since x.x.x
      # @api private
      def force?(env)
        !ssl?(env)
      end

      private

      # @since x.x.x
      # @api private
      attr_reader :host

      # Return full url to redirect
      #
      # @param request [Rack::Request] a Rack request
      #
      # @return [String]
      #
      # @since x.x.x
      # @api private
      def full_url(env)
        "#{ SSL_SCHEME }://#{ host }:#{ port }#{ ::Rack::Request.new(env).fullpath }"
      end

      # Return redirect code
      #
      # @param request [Rack::Request] a Rack request
      #
      # @return [Integer]
      #
      # @since x.x.x
      # @api private
      def redirect_code(env)
        if IDEMPOTENT_METHODS.include?(env[REQUEST_METHOD])
          MOVED_PERMANENTLY_HTTP_CODE
        else
          TEMPORARY_REDIRECT_HTTP_CODE
        end
      end

      # Return correct default port for full url
      #
      # @return [Integer]
      #
      # @since x.x.x
      # @api private
      def port
        if @port == DEFAULT_HTTP_PORT
          DEFAULT_SSL_PORT
        else
          @port
        end
      end

      # @since x.x.x
      # @api private
      def _redefine_call
        return unless @active

        define_singleton_method :call do |env|
          [redirect_code(env), { LOCATION_HEADER => full_url(env) }, EMPTY_BODY] if force?(env)
        end
      end

      # Adapted from Rack::Request#scheme
      #
      # @since x.x.x
      # @api private
      def scheme(env)
        if env[HTTPS] == ON
          SSL_SCHEME
        elsif env[HTTP_X_FORWARDED_SSL] == ON
          SSL_SCHEME
        elsif env[HTTP_X_FORWARDED_SCHEME]
          env[HTTP_X_FORWARDED_SCHEME]
        elsif env[HTTP_X_FORWARDED_PROTO]
          env[HTTP_X_FORWARDED_PROTO].split(HTTP_X_FORWARDED_PROTO_SEPARATOR)[0]
        else
          env[RACK_URL_SCHEME]
        end
      end

      # @since x.x.x
      # @api private
      def ssl?(env)
        scheme(env) == SSL_SCHEME
      end
    end
  end
end
