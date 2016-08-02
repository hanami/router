require 'hanami/routing/parsing/parser'

module Hanami
  module Routing
    class Parsers
      CONTENT_TYPE       = 'CONTENT_TYPE'.freeze
      MEDIA_TYPE_MATCHER = /\s*[;,]\s*/.freeze

      RACK_INPUT    = 'rack.input'.freeze
      ROUTER_PARAMS = 'router.params'.freeze
      ROUTER_PARSED_BODY = 'router.parsed_body'.freeze
      FALLBACK_KEY  = '_'.freeze

      def initialize(parsers)
        @parsers = prepare(parsers)
        _redefine_call
      end

      def call(env)
        env
      end

      private
      def prepare(args)
        result  = Hash.new
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

      def _redefine_call
        return if @parsers.empty?

        define_singleton_method :call do |env|
          body = env[RACK_INPUT].read
          return env if body.empty?

          env[RACK_INPUT].rewind    # somebody might try to read this stream

          env[ROUTER_PARAMS] ||= {} # prepare params
          parsed_body = _parse(env, body)
          env[ROUTER_PARSED_BODY] = parsed_body
          env[ROUTER_PARAMS].merge!(parsed_body)

          env
        end
      end

      def _parse(env, body)
        result = @parsers[
          media_type(env)
        ].parse(body)

        case result
        when Hash
          result
        else
          {FALLBACK_KEY => result}
        end
      end

      def media_type(env)
        if ct = content_type(env)
          ct.split(MEDIA_TYPE_MATCHER, 2).first.downcase
        end
      end

      def content_type(env)
        content_type = env[CONTENT_TYPE]
        content_type.nil? || content_type.empty? ? nil : content_type
      end
    end
  end
end
