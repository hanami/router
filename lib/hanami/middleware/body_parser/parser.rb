# frozen_string_literal: true

require "hanami/middleware"
require "hanami/utils/class"
require "hanami/utils/string"
require "hanami/routing"

module Hanami
  module Middleware
    class BodyParser
      # Body parsing error
      # This is raised when parser fails to parse the body
      #
      # @since x.x.x
      class BodyParsingError < Hanami::Middleware::Error
      end

      # @since x.x.x
      class UnknownParserError < Hanami::Middleware::Error
        # @api private
        def initialize(parser)
          super("Unknown Parser: `#{parser}'")
        end
      end

      # @since 1.3.0
      class Parser
        # @since 1.3.0
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

        # @since 1.3.0
        def mime_types
          raise NotImplementedError
        end

        # @since 1.3.0
        def parse(body)
          body
        end

        private

        # @since 1.3.0
        # @api private
        def self.require_parser(parser)
          require "hanami/middleware/body_parser/#{parser}_parser"

          parser = Utils::String.classify(parser)
          Utils::Class.load!("Hanami::Middleware::BodyParser::#{parser}Parser").new
        rescue LoadError, NameError
          raise UnknownParserError.new(parser)
        end

        private_class_method :require_parser

        def self.parser?(parser)
          parser.is_a?(Class) && parser < Parser
        end

        private_class_method :parser?
      end
    end
  end
end
