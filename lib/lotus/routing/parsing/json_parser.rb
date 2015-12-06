require 'json'

module Lotus
  module Routing
    module Parsing
      # Json parsing error
      # This is raised when the json parser fails to parse a json string.
      #
      # @since x.x.x
      class JsonParsingException < ::StandardError
      end

      class JsonParser < Parser
        def mime_types
          ['application/json', 'application/vnd.api+json']
        end

        def parse(body)
          JSON.parse(body)
        rescue JSON::ParserError => e
          raise JsonParsingException.new(e.message)
        end
      end
    end
  end
end
