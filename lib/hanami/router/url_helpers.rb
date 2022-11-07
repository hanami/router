# frozen_string_literal: true

require "hanami/router/errors"
require "mustermann/error"

module Hanami
  class Router
    # @since 2.0.0
    # @api private
    class UrlHelpers
      # @since 2.0.0
      # @api private
      def initialize(base_url)
        @base_url = base_url
        @named = {}
      end

      # @since 2.0.0
      # @api private
      def add(name, segment)
        @named[name] = segment
      end

      # @since 2.0.0
      # @api private
      def path(name, variables = {})
        @named.fetch(name.to_sym) do
          raise MissingRouteError.new(name)
        end.expand(:append, variables)
      rescue Mustermann::ExpandError => exception
        raise InvalidRouteExpansionError.new(name, exception.message)
      end

      # @since 2.0.0
      # @api private
      def url(name, variables = {})
        @base_url + path(name, variables)
      end
    end
  end
end
