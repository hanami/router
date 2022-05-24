# frozen_string_literal: true

module Hanami
  module Middleware
    class BodyParser
      # Body parser abstract class
      #
      # @since 2.0.0
      class Parser
        # Declare supported MIME types
        #
        # @return [Array<String>] supported MIME types
        #
        # @abstract
        # @since 2.0.0
        #
        # @example
        #   require "hanami/middleware/body_parser"
        #
        #   class XMLParser < Hanami::Middleware::BodyParser::Parser
        #     def mime_types
        #       ["application/xml", "text/xml"]
        #     end
        #   end
        def mime_types
          raise NoMethodError
        end

        # Parse raw HTTP request body
        #
        # @param body [String] HTTP request body
        #
        # @return [Hash] the result of the parsing
        #
        # @raise [Hanami::Middleware::BodyParser::BodyParsingError] the error
        #   that must be raised if the parsing cannot be accomplished
        #
        # @abstract
        # @since 2.0.0
        #
        # @example
        #   require "hanami/middleware/body_parser"
        #
        #   class XMLParser < Hanami::Middleware::BodyParser::Parser
        #     def parse(body)
        #       # XML parsing
        #       # ...
        #     rescue => exception
        #       raise Hanami::Middleware::BodyParser::BodyParsingError.new(exception.message)
        #     end
        #   end
        def parse(_body)
          raise NoMethodError
        end
      end
    end
  end
end
