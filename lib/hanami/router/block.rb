# frozen_string_literal: true

module Hanami
  class Router
    # Block endpoint
    #
    # @api private
    # @since x.x.x
    class Block
      # Context to handle a single incoming HTTP request for a block endpoint
      #
      # @since x.x.x
      class Context
        # @api private
        # @since x.x.x
        def initialize(blk, env)
          @blk = blk
          @env = env
        end

        # Rack env
        #
        # @return [Hash] the Rack env
        #
        # @since x.x.x
        attr_reader :env

        # @overload status
        #   Gets the current HTTP status code
        #   @return [Integer] the HTTP status code
        # @overload status(value)
        #   Sets the HTTP status
        #   @param value [Integer] the HTTP status code
        def status(value = nil)
          if value
            @status = value
          else
            @status ||= 200
          end
        end

        # @overload headers
        #   Gets the current HTTP headers code
        #   @return [Integer] the HTTP headers code
        # @overload headers(value)
        #   Sets the HTTP headers
        #   @param value [Integer] the HTTP headers code
        def headers(value = nil)
          if value
            @headers = value
          else
            @headers ||= {}
          end
        end

        # HTTP Params from URL variables and HTTP body parsing
        #
        # @return [Hash] the HTTP params
        #
        # @since x.x.x
        def params
          env["router.params"]
        end

        # @api private
        # @since x.x.x
        def call
          body = instance_exec(&@blk)
          [status, headers, [body]]
        end
      end

      # @api private
      # @since x.x.x
      def initialize(context_class, blk)
        @context_class = context_class || Context
        @blk = blk
        freeze
      end

      # @api private
      # @since x.x.x
      def call(env)
        @context_class.new(@blk, env).call
      end
    end
  end
end
