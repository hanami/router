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

        def status
          200
        end

        def headers
          {}
        end

        def params
          env["router.params"]
        end

        # @api private
        def call
          [status, headers, [instance_exec(&@blk)]]
        end
      end

      # @api private
      def initialize(blk)
        @blk = blk
        freeze
      end

      # @api private
      def call(env)
        Context.new(@blk, env).call
      end
    end
  end
end
