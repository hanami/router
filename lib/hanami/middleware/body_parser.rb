require 'hanami/middleware/parsing/parser'
require 'hanami/utils/hash'

module Hanami
  module Middleware
    # @since 0.2.0
    # @api private
    class BodyParser
      # @since 0.2.0
      # @api private
      CONTENT_TYPE       = 'CONTENT_TYPE'.freeze

      # @since 0.2.0
      # @api private
      MEDIA_TYPE_MATCHER = /\s*[;,]\s*/.freeze

      # @since 0.2.0
      # @api private
      RACK_INPUT    = 'rack.input'.freeze

      # @since 0.2.0
      # @api private
      ROUTER_PARAMS = 'router.params'.freeze

      # @api private
      ROUTER_PARSED_BODY = 'router.parsed_body'.freeze

      # @api private
      FALLBACK_KEY  = '_'.freeze

      # @since 0.2.0
      # @api private
      def self.new(parsers)
        body_parser = super(build_parsers(parsers))
        body_parser.middleware
      end

      def self.build_parsers(parsers)
        result  = Hash.new
        args    = Array(parsers)
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

      def initialize(parsers)
        @parsers = parsers
      end

      def middleware
        Class.new do

          # We do not have access to the scope of BodyParser, we have to find a way to pass the
          # parser to the Middleware, we use this method to set the previous built parsers so
          # later we can access them
          class << self
            attr_reader :parsers

            def set_parsers(parsers)
              @parsers = parsers
              self
            end
          end

          def initialize(app)
            @app = app
          end

          def call(env)
            body = env[RACK_INPUT].read
            return env if body.empty?

            env[RACK_INPUT].rewind    # somebody might try to read this stream

            env[ROUTER_PARAMS] ||= {} # prepare params
            env[ROUTER_PARSED_BODY] = _parse(env, body)
            env[ROUTER_PARAMS]      = _symbolize(env[ROUTER_PARSED_BODY]).merge(env[ROUTER_PARAMS])

            @app.call(env)
          end

          private

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
            self.class.parsers[
              media_type(env)
            ].parse(body)
          end

          # @api private
          def media_type(env)
            if ct = content_type(env)
              ct.split(MEDIA_TYPE_MATCHER, 2).first.downcase
            end
          end

          # @api private
          def content_type(env)
            content_type = env[CONTENT_TYPE]
            content_type.nil? || content_type.empty? ? nil : content_type
          end
        end.set_parsers(@parsers)
      end
    end
  end
end
