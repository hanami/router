# frozen_string_literal: true

require "rack/request"
require "rack/response"

module Hanami
  class Router
    # Block endpoint
    #
    # @api private
    class Block
      # Context to handle a single incoming HTTP request for a block endpoint
      class Context
        # @api private
        def initialize(blk, env)
          @blk = blk
          @env = env
        end

        attr_reader :env

        def request
          @request ||= Request.new(env, env["router.params"])
        end
        alias req request

        def response
          @response ||= Response.new
        end
        alias res response

        # @api private
        def call
          body = instance_exec(&@blk)
          [response.status, response.headers, [body]]
        end
      end

      # Block request
      class Request < Rack::Request
        def initialize(env, params)
          super(env)
          @params = params
        end
      end

      # Block response
      class Response < Rack::Response
      end

      # @api private
      def initialize(context_class, blk)
        @context_class = context_class || Context
        @blk = blk
        freeze
      end

      # @api private
      def call(env)
        @context_class.new(@blk, env).call
      end
    end
  end
end
