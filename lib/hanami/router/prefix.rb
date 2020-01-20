# frozen_string_literal: true

module Hanami
  class Router
    # URL Path prefix
    #
    # @since x.x.x
    # @api private
    class Prefix
      def initialize(prefix)
        @prefix = prefix
      end

      def join(path)
        self.class.new(
          _join(path)
        )
      end

      def relative_join(path, separator = DEFAULT_SEPARATOR)
        _join(path.to_s)
          .gsub(DEFAULT_SEPARATOR_REGEXP, separator)[1..-1]
      end

      def to_s
        @prefix
      end

      def to_sym
        @prefix.to_sym
      end

      private

      DEFAULT_SEPARATOR = "/"
      DEFAULT_SEPARATOR_REGEXP = /\//.freeze
      DOUBLE_DEFAULT_SEPARATOR_REGEXP = /[\/]{2,}/.freeze

      def _join(path)
        (@prefix + DEFAULT_SEPARATOR + path)
          .gsub(DOUBLE_DEFAULT_SEPARATOR_REGEXP, DEFAULT_SEPARATOR)
      end
    end
  end
end
