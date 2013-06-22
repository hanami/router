module Lotus
  module Routing
    class Endpoint < SimpleDelegator
    end

    class ClassEndpoint < Endpoint
      def call(env)
        __getobj__.new.call(env)
      end
    end

    class LazyEndpoint < Endpoint
      def initialize(name, namespace)
        @name, @namespace = name, namespace
      end

      def __getobj__
        @namespace.const_get(@name).new
      end
    end
  end
end
