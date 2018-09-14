require_relative 'errors'
require_relative 'parser'

module Hanami
  module Middleware
    class BodyParser
      module ClassInterface
        # @since x.x.x
        # @api private
        def for(parser)
          if parser_name?(parser)
            require_parser(parser)
          elsif parser_class?(parser)
            parser.new
          elsif parser_instance?(parser)
            parser
          else
            raise UnknownParserError.new(parser)
          end
        end

        private

        # @since 1.3.0
        # @api private
        def require_parser(parser)
          require "hanami/middleware/body_parser/#{parser}_parser"

          parser = Utils::String.classify(parser)
          Utils::Class.load!("Hanami::Middleware::BodyParser::#{ parser }Parser").new
        rescue LoadError, NameError
          raise UnknownParserError.new(parser)
        end

        # @api private
        def parser_name?(parser)
          parser.is_a?(String) || parser.is_a?(Symbol)
        end

        # @api private
        def parser_class?(parser)
          parser.is_a?(Class) && parser < Parser
        end

        # @api private
        def parser_instance?(parser)
          parser.class < Parser
        end
      end
    end
  end
end
