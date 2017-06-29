# frozen_string_literal: true

require "uri"

# Hanami
#
# @since 0.1.0
module Hanami
  # Hanami routing
  #
  # @since 0.1.0
  # @api private
  module Routing
    # @since x.x.x
    # @api private
    module Uri
      # @since x.x.x
      # @api private
      HTTP  = "http".freeze

      # @since x.x.x
      # @api private
      HTTPS = "https".freeze

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
  end
end
