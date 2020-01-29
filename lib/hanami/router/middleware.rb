# frozen_string_literal: true

module Hanami
  class Router
    # Extend router with Rack Middleare features
    module Middleware
      require "hanami/router/middleware/stack"

      def self.extended(router)
        router.instance_variable_set(:@stack, Stack.new)
        super
      end

      def call(env)
        @middleware.call(env)
      end

      def use(middleware, *args, &blk)
        @stack.use(middleware, args, &blk)
      end

      def scope(path)
        @stack.with(path) do
          super
        end
      end

      def freeze
        @middleware = @stack.finalize(inner)
        remove_instance_variable(:@stack)
        super
      end
    end
  end
end
