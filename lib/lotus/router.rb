require 'http_router'
require 'lotus/endpoint_resolver'
require 'lotus/routing/route'
require 'lotus/routing/namespace'
require 'lotus/routing/resource'
require 'lotus/routing/resources'

HttpRouter::Route::VALID_HTTP_VERBS = %w{GET POST PUT PATCH DELETE HEAD OPTIONS TRACE}

module Lotus
  class Router < HttpRouter
    attr_reader :resolver

    def initialize(options = {}, resolver = EndpointResolver.new)
      super

      @default_scheme = options[:scheme] if options[:scheme]
      @default_host   = options[:host]   if options[:host]
      @default_port   = options[:port]   if options[:port]
      @route_class    = Routing::Route

      @resolver = resolver
    end

    def redirect(path, options = {}, &endpoint)
      get(path).redirect resolver.find(options), options[:code] || 302
    end

    def namespace(name, &blk)
      Routing::Namespace.new(self, name, &blk)
    end

    def resource(name, options = {}, &blk)
      Routing::Resource.new(self, name, options, &blk)
    end

    def resources(name, options = {}, &blk)
      Routing::Resources.new(self, name, options, &blk)
    end

    private
    def add_with_request_method(path, method, opts = {}, &app)
      super.generate(resolver, opts, &app)
    end
  end
end
