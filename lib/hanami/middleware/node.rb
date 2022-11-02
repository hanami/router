# frozen_string_literal: true

module Hanami
  module Middleware
    # Trie node to register scopes with custom Rack middleware
    #
    # @api private
    # @since 2.0.0
    class Node
      # @api private
      # @since 2.0.0
      attr_reader :app

      # @api private
      # @since 2.0.0
      def initialize
        @app = nil
        @children = {}
      end

      # @api private
      # @since 2.0.0
      def freeze
        @children.freeze
        super
      end

      # @api private
      # @since 2.0.0
      def put(segment)
        @children[segment] ||= self.class.new
      end

      # @api private
      # @since 2.0.0
      def get(segment)
        @children.fetch(segment) { self if leaf? }
      end

      # @api private
      # @since 2.0.0
      def app!(app)
        @app = app
      end

      # @api private
      # @since 2.0.0
      def app?
        !@app.nil?
      end

      # @api private
      # @since 2.0.0
      def leaf?
        @children.empty?
      end
    end
  end
end
