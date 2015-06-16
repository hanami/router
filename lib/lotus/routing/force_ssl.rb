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

      # Initialize force ssl class.
      #
      # @param force_ssl [Boolean] activate redirection to ssl
      # @param options [Hash] activate redirection to ssl
      # @option options [String] :default_host
      # @option options [Integer] :default_port
      # @option options [String] :scheme
      #
      # @since x.x.x
      # @api private
      def initialize(force_ssl, options = {})
        @force_ssl      = force_ssl
        @default_host   = options[:host]
        @default_port   = options[:port]
        @default_scheme = options[:scheme]
      end

      # Set 301 status and Location header if force_ssl is activated.
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
        rack_request = ::Rack::Request.new(env)
        [redirect_code(rack_request), { LOCATION_HEADER => full_url(rack_request) }, '']
      end

      # Check if router has to force the response with ssl
      #
      # @return [Boolean]
      #
      # @since x.x.x
      # @api private
      def force?(env)
        rack_request = ::Rack::Request.new(env)
        @force_ssl && !rack_request.scheme.eql?(SSL_SCHEME)
      end

      private

      # Return full url to redirect
      #
      # @param request [Rack::Request] a Rack request
      #
      # @return [String]
      #
      # @since x.x.x
      # @api private
      def full_url(request)
        url = "https://#{@default_host}"
        url.concat(":#{default_port}")
        url.concat(request.fullpath)
      end

      # Return redirect code
      #
      # @param request [Rack::Request] a Rack request
      #
      # @return [Integer]
      #
      # @since x.x.x
      # @api private
      def redirect_code(request)
        if %w(GET HEAD).include? request.request_method
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
      def default_port
        if @default_port.eql? DEFAULT_HTTP_PORT
          DEFAULT_SSL_PORT
        else
          @default_port
        end
      end
    end
  end
end
