require_relative 'errors'

module Hanami
  module Middleware
    class BodyParser
      module ClassInterface
        # @since x.x.x
        # @api private
        def for(parser)
          parser =
            case parser
            when String, Symbol
              require_parser(parser)
            when Class
              parser.new
            else
              parser
            end

          ensure_parser parser

          parser
        end

        private

        # @api private
        PARSER_METHODS = %i[mime_types parse].freeze

        # @api private
        def ensure_parser(parser)
          unless PARSER_METHODS.all? { |method| parser.respond_to?(method) }
            raise UnknownParserError.new(parser)
          end
        end

        # @since 1.3.0
        # @api private
        def require_parser(parser)
          require "hanami/middleware/body_parser/#{parser}_parser"

          parser = Utils::String.classify(parser)
          Utils::Class.load!("Hanami::Middleware::BodyParser::#{ parser }Parser").new
        rescue LoadError, NameError
          raise UnknownParserError.new(parser)
        end
      end
    end
  end
end
