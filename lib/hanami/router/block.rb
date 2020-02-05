# frozen_string_literal: true

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

        def status(value = nil)
          if value
            @status = value
          else
            @status ||= 200
          end
        end

        def headers(value = nil)
          if value
            @headers = value
          else
            @headers ||= {}
          end
        end

        def params
          env["router.params"]
        end

        # @api private
        def call
          body = instance_exec(&@blk)
          [status, headers, [body]]
        end
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
