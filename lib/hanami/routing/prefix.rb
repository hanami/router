# frozen_string_literal: true

require "delegate"
require "hanami/utils/path_prefix"

module Hanami
  module Routing
    # Prefix for routes.
    # Implementation of Hanami::Router#prefix
    #
    # @since x.x.x
    # @api private
    #
    # @see Hanami::Router#prefix
    class Prefix < SimpleDelegator
      # @api private
      # @since x.x.x
      def initialize(router, path, &blk)
        @router = router
        @path   = Utils::PathPrefix.new(path)
        __setobj__(@router)
        instance_eval(&blk)
      end

      # @api private
      # @since x.x.x
      def get(path, options = {}, &endpoint)
        super(@path.join(path), options, &endpoint)
      end

      # @api private
      # @since x.x.x
      def post(path, options = {}, &endpoint)
        super(@path.join(path), options, &endpoint)
      end

      # @api private
      # @since x.x.x
      def put(path, options = {}, &endpoint)
        super(@path.join(path), options, &endpoint)
      end

      # @api private
      # @since x.x.x
      def patch(path, options = {}, &endpoint)
        super(@path.join(path), options, &endpoint)
      end

      # @api private
      # @since x.x.x
      def delete(path, options = {}, &endpoint)
        super(@path.join(path), options, &endpoint)
      end

      # @api private
      # @since x.x.x
      def trace(path, options = {}, &endpoint)
        super(@path.join(path), options, &endpoint)
      end

      # @api private
      # @since x.x.x
      def options(path, options = {}, &endpoint)
        super(@path.join(path), options, &endpoint)
      end

      # @api private
      # @since x.x.x
      def resource(name, options = {})
        super name, options.merge(prefix: @path.relative_join(options[:prefix]))
      end

      # @api private
      # @since x.x.x
      def resources(name, options = {})
        super name, options.merge(prefix: @path.relative_join(options[:prefix]))
      end

      # @api private
      # @since x.x.x
      def redirect(path, options = {}, &endpoint)
        super(@path.join(path), options.merge(to: @path.join(options[:to])), &endpoint)
      end

      # @api private
      # @since x.x.x
      def mount(app, options)
        super(app, options.merge(at: @path.join(options[:at])))
      end

      # Supports nested prefix
      #
      # @api private
      # @since x.x.x
      def prefix(path, &blk)
        self.class.new(self, path, &blk)
      end
    end
  end
end
