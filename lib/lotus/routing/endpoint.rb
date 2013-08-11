require 'delegate'
require 'lotus/utils/class'

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

      def call(env)
        obj.call(env)
      end

      private
      def obj
        Utils::Class.load!(@name, @namespace).new
      end
    end
  end
end
