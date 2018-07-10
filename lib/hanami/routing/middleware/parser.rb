# frozen_string_literal: true

require 'hanami/utils/hash'

module Hanami
  module Routing
    module Middleware
      # Body parsing error
      # This is raised when parser fails to parse the body
      #
      # @since x.x.x
      class BodyParsingError < Hanami::Routing::Error
      end
      # @since x.x.x
      class UnknownParserError < Hanami::Routing::Error
        # @since x.x.x
        # @api private
        def initialize(parser)
          super("Unknown Parser: `#{ parser }'")
        end
      end

      class Parser
        # @since x.x.x
        # @api private
        CONTENT_TYPE       = 'CONTENT_TYPE'.freeze

        # @since x.x.x
        # @api private
        MEDIA_TYPE_MATCHER = /\s*[;,]\s*/.freeze

        # @since x.x.x
        # @api private
        RACK_INPUT    = 'rack.input'.freeze

        # @since x.x.x
        # @api private
        ROUTER_PARAMS = 'router.params'.freeze

        # @api private
        ROUTER_PARSED_BODY = 'router.parsed_body'.freeze

        # @api private
        FALLBACK_KEY  = '_'.freeze

        def initialize(app)
          @app = app
        end

        def call(env)
          body = env[RACK_INPUT].read
          return env if body.empty?

          env[RACK_INPUT].rewind    # somebody might try to read this stream

          if mime_types.include?(media_type(env))
            env[ROUTER_PARAMS] ||= {} # prepare params
            env[ROUTER_PARSED_BODY] = parse(body)
            env[ROUTER_PARAMS]      = symbolize(env[ROUTER_PARSED_BODY]).merge(env[ROUTER_PARAMS])
          end

          @app.call(env)
        end

         # @api public
         def mime_types
          raise NotImplementedError
        end

        # @api public
        def parse(body)
          raise NotImplementedError
        end

        private

        # @api private
        def symbolize(body)
          if body.is_a?(Hash)
            Utils::Hash.deep_symbolize(body)
          else
            { FALLBACK_KEY => body }
          end
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
      end
    end
  end
end
