require 'http_router'
require 'lotus/endpoint_resolver'

module Lotus
  class Router < HttpRouter
    attr_reader :resolver

    def initialize(resolver = EndpointResolver.new)
      super
      @resolver = resolver
    end

    def get(path, options = {})
      super(path, options).to resolver.resolve(options)
    end
  end
end
