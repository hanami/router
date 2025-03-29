# frozen_string_literal: true

require "hanami/router/node"

module Hanami
  class Router
    # Trie data structure to store routes
    #
    # @api private
    # @since 2.0.0
    class Trie
      # @api private
      # @since 2.0.0
      attr_reader :root

      # @api private
      # @since 2.0.0
      def initialize
        @root = Node.new
      end

      # @api private
      # @since 2.0.0
      def add(route, to, constraints)
        segments = segments_from(route)
        param_keys = []
        node = @root

        segments.each do |segment|
          node = node.put(segment, param_keys)
        end

        node.leaf!(param_keys, to, constraints)
      end

      # @api private
      # @since 2.0.0
      def find(path)
        segments = segments_from(path)
        param_values = []
        node = @root

        return unless segments.all? { |segment| node = node.get(segment, param_values) }

        node.match(param_values)&.then { |found| [found.to, found.params] }
      end

      private

      # @api private
      # @since 2.0.0
      SEGMENT_SEPARATOR = "/"
      private_constant :SEGMENT_SEPARATOR

      # @api private
      # @since 2.2.0
      def segments_from(path)
        _, *segments = path.split(SEGMENT_SEPARATOR)

        segments
      end
    end
  end
end
