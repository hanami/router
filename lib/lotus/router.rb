require 'http_router'
require 'lotus/endpoint_resolver'
require 'lotus/routing/namespace'
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

      @resolver = resolver
    end

    def get(path, options = {}, &endpoint)
      super(path, options).tap do |route|
        route.to   resolver.resolve(options, &endpoint)
        route.name = options[:as].to_sym if options[:as]
      end
    end

    def post(path, options = {}, &endpoint)
      super(path, options).tap do |route|
        route.to   resolver.resolve(options, &endpoint)
        route.name = options[:as].to_sym if options[:as]
      end
    end

    def delete(path, options = {}, &endpoint)
      super(path, options).tap do |route|
        route.to   resolver.resolve(options, &endpoint)
        route.name = options[:as].to_sym if options[:as]
      end
    end

    def put(path, options = {}, &endpoint)
      super(path, options).tap do |route|
        route.to   resolver.resolve(options, &endpoint)
        route.name = options[:as].to_sym if options[:as]
      end
    end

    def patch(path, options = {}, &endpoint)
      super(path, options).tap do |route|
        route.to   resolver.resolve(options, &endpoint)
        route.name = options[:as].to_sym if options[:as]
      end
    end

    def trace(path, options = {}, &endpoint)
      super(path, options).tap do |route|
        route.to   resolver.resolve(options, &endpoint)
        route.name = options[:as].to_sym if options[:as]
      end
    end

    def redirect(path, options = {}, &endpoint)
      get(path).redirect resolver.find(options), options[:code] || 302
    end

    def namespace(name, &blk)
      Routing::Namespace.new(self, name, &blk)
    end

    def resources(name, options = {})
      Routing::Resources.new(self, name, options).generate
    end
  end
end
