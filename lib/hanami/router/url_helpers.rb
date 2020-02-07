# frozen_string_literal: true

require "hanami/router/error"
require "mustermann/error"

module Hanami
  class Router
    # URL Helpers
    class UrlHelpers
      def initialize(base_url)
        @base_url = base_url
        @named = {}
      end

      def add(name, segment)
        @named[name] = segment
      end

      def path(name, variables = {})
        @named.fetch(name.to_sym) do
          raise InvalidRouteException.new(name)
        end.expand(:append, variables)
      rescue Mustermann::ExpandError => exception
        raise InvalidRouteExpansionException.new(name, exception.message)
      end

      def url(name, variables = {})
        @base_url + path(name, variables)
      end
    end
  end
end
