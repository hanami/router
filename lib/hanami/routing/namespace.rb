require 'delegate'
require 'hanami/utils/path_prefix'

module Hanami
  module Routing
    # Namespace for routes.
    # Implementation of Hanami::Router#namespace
    #
    # @since 0.1.0
    #
    # @api private
    #
    # @see Hanami::Router#namespace
    class Namespace < SimpleDelegator
      # @api private
      # @since 0.1.0
      def initialize(router, name, &blk)
        @router = router
        @name   = Utils::PathPrefix.new(name)
        __setobj__(@router)
        instance_eval(&blk)
      end

      # @api private
      # @since 0.1.0
      def get(path, options = {}, &endpoint)
        super(@name.join(path), options, &endpoint)
      end

      # @api private
      # @since 0.1.0
      def post(path, options = {}, &endpoint)
        super(@name.join(path), options, &endpoint)
      end

      # @api private
      # @since 0.1.0
      def put(path, options = {}, &endpoint)
        super(@name.join(path), options, &endpoint)
      end

      # @api private
      # @since 0.1.0
      def patch(path, options = {}, &endpoint)
        super(@name.join(path), options, &endpoint)
      end

      # @api private
      # @since 0.1.0
      def delete(path, options = {}, &endpoint)
        super(@name.join(path), options, &endpoint)
      end

      # @api private
      # @since 0.1.0
      def trace(path, options = {}, &endpoint)
        super(@name.join(path), options, &endpoint)
      end

      # @api private
      # @since 0.1.0
      def options(path, options = {}, &endpoint)
        super(@name.join(path), options, &endpoint)
      end

      # @api private
      # @since 0.1.0
      def resource(name, options = {})
        super name, options.merge(namespace: @name.relative_join(options[:namespace]))
      end

      # @api private
      # @since 0.1.0
      def resources(name, options = {})
        super name, options.merge(namespace: @name.relative_join(options[:namespace]))
      end

      # @api private
      # @since 0.1.0
      def redirect(path, options = {}, &endpoint)
        super(@name.join(path), options.merge(to: @name.join(options[:to])), &endpoint)
      end

      # @api private
      # @since x.x.x
      def mount(app, options)
        super(app, options.merge(at: @name.join(options[:at])))
      end

      # Supports nested namespaces
      # @api private
      # @since 0.1.0
      def namespace(name, &blk)
        Routing::Namespace.new(self, name, &blk)
      end
    end
  end
end
