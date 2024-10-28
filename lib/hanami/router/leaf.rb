# frozen_string_literal: true

require "mustermann/rails"

module Hanami
  class Router
    class Leaf
      # Trie Leaf
      #
      # @api private
      # @since 2.1.1
      attr_reader :to, :params

      # @api private
      # @since 2.1.1
      def initialize(route, to, constraints)
        @route = route
        @to = to
        @constraints = constraints
        @params = nil
      end

      # @api private
      # @since 2.1.1
      def match(path)
        match = matcher.match(path)

        @params = match.named_captures if match

        match
      end

      private

      # @api private
      # @since 2.1.1
      def matcher
        @matcher ||= Mustermann.new(@route, type: :rails, version: "5.0", capture: @constraints)
      end
    end
  end
end
