# frozen_string_literal: true

require "mustermann/rails"

module Hanami
  class Router
    class Leaf
      # Trie Leaf
      #
      # @api private
      # @since 2.2.0
      attr_reader :to, :params

      # @api private
      # @since 2.2.0
      def initialize(param_keys, to, constraints)
        @param_keys = param_keys.map { |key| key.delete_prefix(":") }.freeze
        @to = to
        @constraints = constraints
        @params = nil
      end

      # @api private
      # @since 2.2.0
      def match(param_values)
        @params = @param_keys.zip(param_values).to_h

        return true if @constraints.empty?

        @constraints.all? do |key, constraint|
          match = constraint.match(@params[key.to_s])

          match && (match.string == match[0])
        end
      end
    end
  end
end
