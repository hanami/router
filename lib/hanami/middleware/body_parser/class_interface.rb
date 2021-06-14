# frozen_string_literal: true

require_relative "errors"

module Hanami
  module Middleware
    # HTTP request body parser
    class BodyParser
      # @api private
      # @since 1.3.0
      module ClassInterface
        # @api private
        # @since 1.3.0
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
        # @since 1.3.0
        PARSER_METHODS = %i[mime_types parse].freeze

        # @api private
        # @since 1.3.0
        def ensure_parser(parser)
          raise InvalidParserError.new(parser) unless PARSER_METHODS.all? { |method| parser.respond_to?(method) }
        end

        # @api private
        # @since 1.3.0
        def require_parser(parser)
          require "hanami/middleware/body_parser/#{parser}_parser"

          load_parser!("#{classify(parser)}Parser").new
        rescue LoadError, NameError
          raise UnknownParserError.new(parser)
        end

        def classify(parser)
          parser.to_s.split(/_/).map(&:capitalize).join
        end

        def load_parser!(class_name)
          Hanami::Middleware::BodyParser.const_get(class_name, false)
        end
      end
    end
  end
end
