require 'hanami/utils/class'
require 'hanami/utils/string'
require 'hanami/routing/parsing/parser'

module Hanami
  module Middleware
    class BodyParser
      # Body parsing error
      # This is raised when parser fails to parse the body
      #
      # @since x.x.x
      class BodyParsingError < Hanami::Routing::Parsing::BodyParsingError
      end

      # @since x.x.x
      class UnknownParserError < Hanami::Routing::Parsing::UnknownParserError
      end

      # @since x.x.x
      class Parser
        # @since x.x.x
        # @api private
        def self.for(parser)
          case parser
          when String, Symbol
            require_parser(parser)
          else
            raise UnknownParserError.new(parser) unless parser?(parser)
            parser.new
          end
        end

        # @since x.x.x
        def mime_types
          raise NotImplementedError
        end

        # @since x.x.x
        def parse(body)
          body
        end

        private
        # @since x.x.x
        # @api private
        def self.require_parser(parser)
          require "hanami/middleware/body_parser/#{ parser }_parser"

          parser = Utils::String.classify(parser)
          Utils::Class.load!("Hanami::Middleware::BodyParser::#{ parser }Parser").new
        rescue LoadError, NameError
          raise UnknownParserError.new(parser)
        end

        def self.parser?(parser)
          parser.is_a?(Class) && parser < Parser
        end
      end
    end
  end
end
