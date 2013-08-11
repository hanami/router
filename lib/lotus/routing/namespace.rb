require 'delegate'
require 'lotus/utils/path_prefix'

module Lotus
  module Routing
    class Namespace < SimpleDelegator
      def initialize(router, name, &blk)
        @router = router
        @name   = Utils::PathPrefix.new(name)
        __setobj__(@router)
        instance_eval(&blk)
      end

      def get(path, options = {}, &endpoint)
        super(@name.join(path), options, &endpoint)
      end

      def post(path, options = {}, &endpoint)
        super(@name.join(path), options, &endpoint)
      end

      def put(path, options = {}, &endpoint)
        super(@name.join(path), options, &endpoint)
      end

      def patch(path, options = {}, &endpoint)
        super(@name.join(path), options, &endpoint)
      end

      def delete(path, options = {}, &endpoint)
        super(@name.join(path), options, &endpoint)
      end

      def trace(path, options = {}, &endpoint)
        super(@name.join(path), options, &endpoint)
      end

      def resources(name, options = {})
        super name, options.merge(prefix: @name)
      end

      def redirect(path, options = {}, &endpoint)
        super(@name.join(path), options.merge(prefix: @name), &endpoint)
      end

      def namespace(name, &blk)
        Routing::Namespace.new(self, name, &blk)
      end
    end
  end
end
