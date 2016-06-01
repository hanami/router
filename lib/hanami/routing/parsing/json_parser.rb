require 'hanami/utils/json'

module Hanami
  module Routing
    module Parsing
      class JsonParser < Parser
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
        def parse(body)
          Hanami::Utils::Json.load(body)
        rescue Hanami::Utils::Json::ParserError => e
          raise BodyParsingError.new(e.message)
        end
      end
    end
  end
end
