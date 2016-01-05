require 'lotus/utils/class'
require 'lotus/utils/string'
require 'lotus/routing/error'

module Lotus
  module Routing
    module Parsing
      # Body parsing error
      # This is raised when parser fails to parse the body
      #
      # @since x.x.x
      class BodyParsingError < Lotus::Routing::Error
      end

      class UnknownParserError < Lotus::Routing::Error
        def initialize(parser)
          super("Unknown Parser: `#{ parser }'")
        end
      end

      class Parser
        def self.for(parser)
          case parser
          when String, Symbol
            require_parser(parser)
          else
            parser
          end
        end

        def mime_types
          raise NotImplementedError
        end

        def parse(body)
          Hash.new
        end

        private
        def self.require_parser(parser)
          require "lotus/routing/parsing/#{ parser }_parser"

          parser = Utils::String.new(parser).classify
          Utils::Class.load!("Lotus::Routing::Parsing::#{ parser }Parser").new
        rescue LoadError, NameError
          raise UnknownParserError.new(parser)
        end
      end
    end
  end
end
