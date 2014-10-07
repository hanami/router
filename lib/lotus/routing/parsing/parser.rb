require 'lotus/utils/class'
require 'lotus/utils/string'

module Lotus
  module Routing
    module Parsing
      class UnknownParserError < ::StandardError
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
