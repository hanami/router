# frozen_string_literal: true

require "hanami/middleware/body_parser/parser"
require "hanami/utils/hash"

module Hanami
  module Middleware
    # @since x.x.x
    # @api private
    class BodyParser
      # @since x.x.x
      # @api private
      CONTENT_TYPE       = "CONTENT_TYPE"

      # @since x.x.x
      # @api private
      MEDIA_TYPE_MATCHER = /\s*[;,]\s*/

      # @since x.x.x
      # @api private
      RACK_INPUT    = "rack.input"

      # @since x.x.x
      # @api private
      ROUTER_PARAMS = "router.params"

      # @api private
      ROUTER_PARSED_BODY = "router.parsed_body"

      # @api private
      FALLBACK_KEY = "_"

      def initialize(app, parsers)
        @app = app
        @parsers = build_parsers(parsers)
      end

      def call(env)
        body = env[RACK_INPUT].read
        return @app.call(env) if body.empty?

        env[RACK_INPUT].rewind    # somebody might try to read this stream

        env[ROUTER_PARAMS] ||= {} # prepare params
        env[ROUTER_PARSED_BODY] = _parse(env, body)
        env[ROUTER_PARAMS]      = _symbolize(env[ROUTER_PARSED_BODY]).merge(env[ROUTER_PARAMS])

        @app.call(env)
      end

      private

      def build_parsers(parsers) # rubocop:disable Metrics/MethodLength
        result  = {}
        args    = Array(parsers)
        return result if args.empty?

        args.each do |arg|
          parser = Parser.for(arg)

          parser.mime_types.each do |mime|
            result[mime] = parser
          end
        end

        result.default = Parser.new
        result
      end

      # @api private
      def _symbolize(body)
        if body.is_a?(Hash)
          Utils::Hash.deep_symbolize(body)
        else
          { FALLBACK_KEY => body }
        end
      end

      # @api private
      def _parse(env, body)
        @parsers[
          media_type(env)
        ].parse(body)
      end

      # @api private
      def media_type(env)
        ct = content_type(env)
        return unless ct
        ct.split(MEDIA_TYPE_MATCHER, 2).first.downcase
      end

      # @api private
      def content_type(env)
        content_type = env[CONTENT_TYPE]
        content_type.nil? || content_type.empty? ? nil : content_type
      end
    end
  end
end
