# frozen_string_literal: true

require "rack/builder"

module Hanami
  class Router
    module Middleware
      # Middleware stack
      class Stack
        ROOT_PREFIX = "/"
        private_constant :ROOT_PREFIX

        def initialize
          @prefix = ROOT_PREFIX
          @stack = Hash.new { |hash, key| hash[key] = [] }
        end

        def use(middleware, args, &blk)
          @stack[@prefix].push([middleware, args, blk])
        end

        def with(path)
          prefix = @prefix
          @prefix = path
          yield
        ensure
          @prefix = prefix
        end

        def finalize(app) # rubocop:disable Metrics/MethodLength
          return app if @stack.empty?

          s = self

          Rack::Builder.new do
            s.each do |prefix, stack|
              s.mapped(self, prefix) do
                stack.each do |middleware, args, blk|
                  use(middleware, *args, &blk)
                end
              end

              run app
            end
          end
        end

        def each(&blk)
          @stack.each(&blk)
        end

        def mapped(builder, prefix, &blk)
          if prefix == ROOT_PREFIX
            builder.instance_eval(&blk)
          else
            builder.map(prefix, &blk)
          end
        end
      end
    end
  end
end
