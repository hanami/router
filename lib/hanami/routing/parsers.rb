# frozen_string_literal: true

require "hanami/routing/parsing/parser"
require "hanami/utils/hash"

module Hanami
  module Routing
    # @since 0.2.0
    # @api private
    class Parsers
      # @since 0.2.0
      # @api private
      CONTENT_TYPE       = "CONTENT_TYPE"

      # @since 0.2.0
      # @api private
      MEDIA_TYPE_MATCHER = /\s*[;,]\s*/

      # @since 0.2.0
      # @api private
      RACK_INPUT    = "rack.input"

      # @since 0.2.0
      # @api private
      ROUTER_PARAMS = "router.params"

      # @api private
      ROUTER_PARSED_BODY = "router.parsed_body"

      # @api private
      FALLBACK_KEY = "_"

      # @since 0.2.0
      # @api private
      def initialize(parsers)
        @parsers = prepare(parsers)
        _redefine_call
      end

      # @since 0.2.0
      # @api private
      def call(env)
        env
      end

      private

      # @since 0.2.0
      # @api private
      def prepare(args) # rubocop:disable Metrics/MethodLength
        result  = {}
        args    = Array(args)
        return result if args.empty?

        args.each do |arg|
          parser = Parsing::Parser.for(arg)

          parser.mime_types.each do |mime|
            result[mime] = parser
          end
        end

        result.default = Parsing::Parser.new
        result
      end

      # @since 0.2.0
      # @api private
      def _redefine_call
        return if @parsers.empty?

        define_singleton_method :call do |env|
          body = env[RACK_INPUT].read
          return env if body.empty?

          env[RACK_INPUT].rewind    # somebody might try to read this stream

          env[ROUTER_PARAMS] ||= {} # prepare params
          env[ROUTER_PARSED_BODY] = _parse(env, body)
          env[ROUTER_PARAMS]      = _symbolize(env[ROUTER_PARSED_BODY]).merge(env[ROUTER_PARAMS])

          env
        end
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
        if (ct = content_type(env)) # rubocop:disable Style/GuardClause
          ct.split(MEDIA_TYPE_MATCHER, 2).first.downcase
        end
      end

      # @api private
      def content_type(env)
        content_type = env[CONTENT_TYPE]
        content_type.nil? || content_type.empty? ? nil : content_type
      end
    end
  end
end
