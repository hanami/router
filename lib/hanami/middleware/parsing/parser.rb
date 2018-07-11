require 'hanami/utils/class'
require 'hanami/utils/string'
require 'hanami/routing/error'

module Hanami
  module Middleware
    module Parsing
      # @since 0.2.0
      class Parser
        # @since 0.2.0
        # @api private
        def self.for(parser)
          case parser
          when String, Symbol
            require_parser(parser)
          else
            raise Hanami::Routing::Parsing::UnknownParserError.new(parser) unless parser?(parser)
            parser.new
          end
        end

        # @since 0.2.0
        def mime_types
          raise NotImplementedError
        end

        # @since 0.2.0
        def parse(body)
          body
        end

        private
        # @since 0.2.0
        # @api private
        def self.require_parser(parser)
          require "hanami/middleware/parsing/#{ parser }_parser"

          parser = Utils::String.classify(parser)
          Utils::Class.load!("Hanami::Middleware::Parsing::#{ parser }Parser").new
        rescue LoadError, NameError
          raise Hanami::Routing::Parsing::UnknownParserError.new(parser)
        end

        def self.parser?(parser)
          parser.is_a?(Class) && parser < Parser
        end
      end
    end
  end
end
