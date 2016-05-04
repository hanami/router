begin
  require 'multi_json'
rescue LoadError
  require 'json'
end

module Hanami
  module Routing
    module Parsing
      class JsonParser < Parser
        unless defined?(MultiJson)
          MultiJson             = JSON
          MultiJson::ParseError = JSON::ParserError
        end

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
          MultiJson.load(body)
        rescue MultiJson::ParseError => e
          raise BodyParsingError.new(e.message)
        end
      end
    end
  end
end
