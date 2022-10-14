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
        # @since 2.0.0
        def new(app, parser_specs)
          super(app, build_parsers(parser_specs))
        end

        # @api private
        # @since 1.3.0
        def build(parser, **config)
          parser =
            case parser
            when String, Symbol
              build(parser_class(parser), **config)
            when Class
              parser.new(**config)
            else
              parser
            end

          ensure_parser parser

          parser
        end

        # @api private
        # @since 2.0.0
        def build_parsers(parser_specs)
          parsers = Array(parser_specs).flatten(0)

          return {} if parsers.empty?

          parsers.each_with_object({}) do |spec, memo|
            name, *mime_types = Array(*spec).flatten(0)
            parser = build(name, mime_types: mime_types)

            parser.mime_types.each do |mime|
              memo[mime] = parser
            end
          end
        end

        private

        # @api private
        # @since 1.3.0
        PARSER_METHODS = %i[mime_types parse].freeze

        # @api private
        # @since 1.3.0
        def ensure_parser(parser)
          unless PARSER_METHODS.all? { |method| parser.respond_to?(method) }
            raise InvalidParserError.new(parser)
          end
        end

        # @api private
        # @since 1.3.0
        def parser_class(parser_name)
          require "hanami/middleware/body_parser/#{parser_name}_parser"

          load_parser!("#{classify(parser_name)}Parser")
        rescue LoadError, NameError
          raise UnknownParserError, parser_name
        end

        # @api private
        # @since 1.3.0
        def classify(parser)
          parser.to_s.split(/_/).map(&:capitalize).join
        end

        # @api private
        # @since 1.3.0
        def load_parser!(class_name)
          Hanami::Middleware::BodyParser.const_get(class_name, false)
        end
      end
    end
  end
end
