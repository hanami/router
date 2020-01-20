# frozen_string_literal: true

require "hanami/router/node"

module Hanami
  class Router
    # Trie data structure to store routes
    #
    # @api private
    # @since x.x.x
    class Trie
      attr_reader :root

      def initialize
        @root = Node.new
      end

      def add(path, to, constraints)
        node = @root
        for_each_segment(path) do |segment|
          node = node.put(segment, constraints)
        end

        node.leaf!(to)
      end

      def find(path)
        node = @root
        params = {}

        for_each_segment(path) do |segment|
          break unless node

          child, captures = node.get(segment)
          params.merge!(captures) if captures

          node = child
        end

        return [node.to, params] if node&.leaf?

        nil
      end

      private

      def for_each_segment(path, &blk)
        # _, *segments = path.split(/\/(?:\()*/)
        _, *segments = path.split(/\//)
        segments.each(&blk)
      end
    end
  end
end
