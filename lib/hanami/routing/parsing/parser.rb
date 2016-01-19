require 'hanami/utils/class'
require 'hanami/utils/string'
require 'hanami/routing/error'

module Hanami
  module Routing
    module Parsing
      # Body parsing error
      # This is raised when parser fails to parse the body
      #
      # @since 0.5.0
      class BodyParsingError < Hanami::Routing::Error
      end

      # @since 0.2.0
      class UnknownParserError < Hanami::Routing::Error
        def initialize(parser)
          super("Unknown Parser: `#{ parser }'")
        end
      end

      # @since 0.2.0
      class Parser
        # @since 0.2.0
        def self.for(parser)
          case parser
          when String, Symbol
            require_parser(parser)
          else
            parser
          end
        end

        # @since 0.2.0
        def mime_types
          raise NotImplementedError
        end

        # @since 0.2.0
        def parse(body)
          Hash.new
        end

        private
        # @since 0.2.0
        # @api private
        def self.require_parser(parser)
          require "hanami/routing/parsing/#{ parser }_parser"

          parser = Utils::String.new(parser).classify
          Utils::Class.load!("Hanami::Routing::Parsing::#{ parser }Parser").new
        rescue LoadError, NameError
          raise UnknownParserError.new(parser)
        end
      end
    end
  end
end
