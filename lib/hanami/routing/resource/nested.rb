# frozen_string_literal: true

module Hanami
  module Routing
    class Resource
      # Helper class to calculate nested path
      #
      # @api private
      # @since 0.4.0
      class Nested
        # @api private
        # @since 0.4.0
        SEPARATOR = "/"

        # @api private
        # @since 0.4.0
        def initialize(resource_name, resource)
          @resource_name = resource_name.to_s.split(SEPARATOR)
          @resource      = resource
          @path          = []
          _calculate(@resource_name.dup, @resource)
        end

        # @api private
        # @since 0.4.0
        def to_path
          @path.reverse!.pop
          @resource_name.zip(@path).flatten.join
        end

        private

        # @api private
        # @since 0.4.0
        def _calculate(param_wildcard, resource = nil)
          return if resource.nil?
          @path << resource.wildcard_param(param_wildcard.pop)
          _calculate(param_wildcard, resource.parent)
        end
      end
    end
  end
end
