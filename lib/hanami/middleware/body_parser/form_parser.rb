# frozen_string_literal: true

require_relative "parser"
require "rack/multipart"

module Hanami
  module Middleware
    class BodyParser
      # @since 2.0.0
      # @api private
      class FormParser < Parser
        # @since 2.0.0
        # @api private
        MIME_TYPES = [
          "application/x-www-form-urlencoded",
          "multipart/form-data"
        ].freeze

        # @since 2.0.0
        # @api private
        def self.mime_types
          MIME_TYPES
        end

        # Parse a json string
        #
        # @param body [String] a json string
        #
        # @return [Hash] the parsed json
        #
        # @raise [Hanami::Middleware::BodyParser::BodyParsingError] when the body can't be parsed.
        #
        # @since 2.0.0
        # @api private
        def parse(*, env)
          ::Rack::Multipart.parse_multipart(env)
        rescue StandardError => exception
          raise BodyParsingError.new(exception.message)
        end
      end
    end
  end
end
