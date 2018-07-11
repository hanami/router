require 'hanami/utils/json'

module Hanami
  module Middleware
    module Parsing
      # @since 0.2.0
      # @api private
      class JsonParser < Parser
        # @since 0.2.0
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
        # @raise [Hanami::Routing::Parsing::BodyParsingError] when the body can't be parsed.
        #
        # @since 0.2.0
        # @api private
        def parse(body)
          Hanami::Utils::Json.parse(body)
        rescue Hanami::Utils::Json::ParserError => e
          raise Hanami::Routing::Parsing::BodyParsingError.new(e.message)
        end
      end
    end
  end
end
