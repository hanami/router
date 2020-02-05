# frozen_string_literal: true

module Hanami
  class Router
    # Params utilities
    #
    # @since x.x.x
    # @api private
    class Params
      def self.deep_symbolize(params) # rubocop:disable Metrics/MethodLength
        params.each_with_object({}) do |(key, value), output|
          output[key.to_sym] =
            case value
            when ::Hash
              deep_symbolize(value)
            when Array
              value.map do |item|
                item.is_a?(::Hash) ? deep_symbolize(item) : item
              end
            else
              value
            end
        end
      end
    end
  end
end
