require 'json'

module Lotus
  module Routing
    module Parsing
      class JsonParser < Parser
        def mime_types
          ['application/json']
        end

        def parse(body)
          JSON.parse(body)
        end
      end
    end
  end
end
