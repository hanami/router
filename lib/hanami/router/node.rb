# frozen_string_literal: true

require "hanami/router/segment"

module Hanami
  class Router
    # Trie node
    #
    # @api private
    # @since x.x.x
    class Node
      # @api private
      # @since x.x.x
      attr_reader :to

      # @api private
      # @since x.x.x
      def initialize
        @variable = nil
        @fixed = nil
        @to = nil
      end

      # @api private
      # @since x.x.x
      def put(segment, constraints)
        if variable?(segment)
          @variable ||= {}
          @variable[segment_for(segment, constraints)] ||= self.class.new
        else
          @fixed ||= {}
          @fixed[segment] ||= self.class.new
        end
      end

      # @api private
      # @since x.x.x
      #
      # rubocop:disable Metrics/MethodLength
      def get(segment)
        return unless @variable || @fixed

        found = nil
        captured = nil

        found = @fixed&.fetch(segment, nil)
        return [found, nil] if found

        @variable&.each do |matcher, node|
          break if found

          captured = matcher.match(segment)
          found = node if captured
        end

        [found, captured&.named_captures]
      end
      # rubocop:enable Metrics/MethodLength

      # @api private
      # @since x.x.x
      def leaf?
        @to
      end

      # @api private
      # @since x.x.x
      def leaf!(to)
        @to = to
      end

      private

      # @api private
      # @since x.x.x
      def variable?(segment)
        /:/.match?(segment)
      end

      # @api private
      # @since x.x.x
      def segment_for(segment, constraints)
        Segment.fabricate(segment, **constraints)
      end

      # @api private
      # @since x.x.x
      def fixed?(matcher)
        matcher.names.empty?
      end
    end
  end
end
