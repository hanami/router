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
      super(path, options).to resolver.resolve(options, &endpoint)
    end

    def redirect(path)
      @routes.find {|r| r.original_path == path } ||
        (raise ArgumentError.new(%(Cannot find route for path: "#{ path }")))
    end
  end
end
