# frozen_string_literal: true

require "hanami/router/segment"

module Hanami
  class Router
    # Trie node
    #
    # @api private
    # @since x.x.x
    class Node
      attr_reader :to

      def initialize
        @variable = nil
        @fixed = nil
        @to = nil
      end

      def put(segment, constraints)
        if variable?(segment)
          @variable ||= {}
          @variable[segment_for(segment, constraints)] ||= self.class.new
        else
          @fixed ||= {}
          @fixed[segment] ||= self.class.new
        end
      end

      # rubocop:disable Metrics/MethodLength
      def get(segment)
        return nil unless @variable || @fixed

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

      def leaf?
        @to
      end

      def leaf!(to)
        @to = to
      end

      private

      def variable?(segment)
        /:/.match?(segment)
      end

      def segment_for(segment, constraints)
        Segment.fabricate(segment, **constraints)
      end

      def fixed?(matcher)
        matcher.names.empty?
      end
    end
  end
end
