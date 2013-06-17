require 'http_router'
require 'lotus/endpoint_resolver'

module Lotus
  class Router < HttpRouter
    attr_reader :resolver

    def initialize(resolver = EndpointResolver.new)
      super
      @resolver = resolver
    end

    def get(path, options = {}, &endpoint)
      super(path, options).tap do |verb|
        verb.to resolver.resolve(options, &endpoint)
      end
    end

    def redirect(path, options = {}, &endpoint)
      get(path).redirect resolver.find(options), options[:code] || 302
    end
  end
end
