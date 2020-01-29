# frozen_string_literal: true

require "rack/utils"

module Hanami
  class Router
    # Params utilities
    #
    # @since x.x.x
    # @api private
    class Params
      PARAMS = "router.params"

      def self.call(env, params)
        params ||= {}
        env[PARAMS] ||= {}
        env[PARAMS].merge!(Rack::Utils.parse_nested_query(env["QUERY_STRING"]))
        env[PARAMS].merge!(params)
        env[PARAMS] = deep_symbolize(env[PARAMS])
        env
      end

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
