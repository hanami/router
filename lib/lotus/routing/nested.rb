module Lotus
  module Routing
    # Helper class to calculate nested path
    #
    # @api private
    # @since x.x.x
    class Nested
      # @api private
      # @since x.x.x
      SLASH = '/'.freeze

      # @api private
      # @since x.x.x
      def initialize(resource_name, resource)
        @resource_name = resource_name.to_s.split(SLASH)
        @resource      = resource
        @path          = []
      end

      # @api private
      # @since x.x.x
      def calculate_nested_path
        _calculate(@resource_name.dup, @resource)
      end

      # @api private
      # @since x.x.x
      def nested_path
        @path.reverse!.pop
        @resource_name.zip(@path).flatten.join
      end

      private

      def _calculate(param_wildcard, resource = nil)
        return if resource.nil?
        @path << resource.wildcard_param(param_wildcard.pop)
        _calculate(param_wildcard, resource.parent_resource)
      end
    end
  end
end