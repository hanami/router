# frozen_string_literal: true

module Hanami
  class Router
    # URL Path prefix
    #
    # @since x.x.x
    # @api private
    class Prefix
      # @since x.x.x
      # @api private
      def initialize(prefix)
        @prefix = prefix
      end

      # @since x.x.x
      # @api private
      def join(path)
        self.class.new(
          _join(path)
        )
      end

      # @since x.x.x
      # @api private
      def relative_join(path, separator = DEFAULT_SEPARATOR)
        _join(path.to_s)
          .gsub(DEFAULT_SEPARATOR_REGEXP, separator)[1..-1]
      end

      # @since x.x.x
      # @api private
      def to_s
        @prefix
      end

      # @since x.x.x
      # @api private
      def to_sym
        @prefix.to_sym
      end

      private

      # @since x.x.x
      # @api private
      DEFAULT_SEPARATOR = "/"

      # @since x.x.x
      # @api private
      DEFAULT_SEPARATOR_REGEXP = /\//.freeze

      # @since x.x.x
      # @api private
      DOUBLE_DEFAULT_SEPARATOR_REGEXP = /[\/]{2,}/.freeze

      # @since x.x.x
      # @api private
      def _join(path)
        (@prefix + DEFAULT_SEPARATOR + path)
          .gsub(DOUBLE_DEFAULT_SEPARATOR_REGEXP, DEFAULT_SEPARATOR)
      end
    end
  end
end
