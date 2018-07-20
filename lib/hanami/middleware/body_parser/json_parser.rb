require 'hanami/utils/json'

module Hanami
  module Middleware
    class BodyParser
      # @since x.x.x
      # @api private
      class JsonParser < Parser
        # @since x.x.x
        # @api private
        def mime_types
          ['application/json', 'application/vnd.api+json']
        end

        # Parse a json string
        #
        # @param body [String] a json string
        #
        # @return [Hash] the parsed json
        #
        # @raise [Hanami::Middleware::BodyParser::BodyParsingError] when the body can't be parsed.
        #
        # @since x.x.x
        # @api private
        def parse(body)
          Hanami::Utils::Json.parse(body)
        rescue Hanami::Utils::Json::ParserError => e
          raise BodyParsingError.new(e.message)
        end
      end
    end
  end
end
