# frozen_string_literal: true

require 'hanami/utils/json'
require 'hanami/routing/middleware/parser'

module Hanami
  module Routing
    module Middleware
      class JsonParser < Parser
        def mime_types
          ['application/json', 'application/vnd.api+json']
        end

        def parse(body)
          Hanami::Utils::Json.parse(body)
        rescue Hanami::Utils::Json::ParserError => e
          raise BodyParsingError.new(e.message)
        end
      end

      class BodyParser < ::Rack::Builder
        def add_parser(klass)
          case klass
          when String, Symbol
            parser = Utils::String.classify(klass)
            use Utils::Class.load!("Hanami::Routing::Middleware::#{ parser }Parser")
          else
            raise UnknownParserError.new(klass) unless parser?(klass)
            use klass
          end
        rescue LoadError, NameError
          raise UnknownParserError.new(klass)
        end

        private

        def parser?(klass)
          klass.is_a?(Class) && klass < Parser
        end
      end
    end
  end
end
