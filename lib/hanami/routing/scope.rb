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
    class Scope < SimpleDelegator
      # @api private
      # @since x.x.x
      def initialize(router, prefix, namespace, &blk)
        @router    = router
        @namespace = namespace
        @prefix    = Utils::PathPrefix.new(prefix)
        __setobj__(@router)
        instance_eval(&blk)
      end

      def root(to:, as: :root, **, &blk)
        super(to: to, as: route_name(as), prefix: @prefix, namespace: @namespace, &blk)
      end

      # @api private
      # @since x.x.x
      def get(path, as: nil, **options, &endpoint)
        super(@prefix.join(path), options.merge(as: route_name(as), namespace: @namespace), &endpoint)
      end

      # @api private
      # @since x.x.x
      def post(path, as: nil, **options, &endpoint)
        super(@prefix.join(path), options.merge(as: route_name(as), namespace: @namespace), &endpoint)
      end

      # @api private
      # @since x.x.x
      def put(path, as: nil, **options, &endpoint)
        super(@prefix.join(path), options.merge(as: route_name(as), namespace: @namespace), &endpoint)
      end

      # @api private
      # @since x.x.x
      def patch(path, as: nil, **options, &endpoint)
        super(@prefix.join(path), options.merge(as: route_name(as), namespace: @namespace), &endpoint)
      end

      # @api private
      # @since x.x.x
      def delete(path, as: nil, **options, &endpoint)
        super(@prefix.join(path), options.merge(as: route_name(as), namespace: @namespace), &endpoint)
      end

      # @api private
      # @since x.x.x
      def trace(path, as: nil, **options, &endpoint)
        super(@prefix.join(path), options.merge(as: route_name(as), namespace: @namespace), &endpoint)
      end

      # @api private
      # @since x.x.x
      def options(path, as: nil, **options, &endpoint)
        super(@prefix.join(path), options.merge(as: route_name(as), namespace: @namespace), &endpoint)
      end

      # @api private
      # @since x.x.x
      def resource(name, options = {})
        super(name, options.merge(prefix: @prefix.relative_join(options[:prefix]), namespace: @namespace))
      end

      # @api private
      # @since x.x.x
      def resources(name, options = {})
        super(name, options.merge(prefix: @prefix.relative_join(options[:prefix]), namespace: @namespace))
      end

      # @api private
      # @since x.x.x
      def redirect(path, options = {}, &endpoint)
        super(@prefix.join(path), options.merge(to: @prefix.join(options[:to])), &endpoint)
      end

      # @api private
      # @since x.x.x
      def mount(app, options)
        super(app, options.merge(at: @prefix.join(options[:at])))
      end

      # @api private
      # @since x.x.x
      def prefix(path, &blk)
        super(@prefix.join(path), namespace: @namespace, &blk)
      end

      private

      ROUTE_NAME_SEPARATOR = "_"

      def route_name(as)
        @prefix.relative_join(as, ROUTE_NAME_SEPARATOR).to_sym unless as.nil?
      end
    end
  end
end
