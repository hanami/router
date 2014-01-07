require 'http_router'
require 'lotus/routing/endpoint_resolver'
require 'lotus/routing/route'
require 'lotus/routing/namespace'
require 'lotus/routing/resource'
require 'lotus/routing/resources'

HttpRouter::Route::VALID_HTTP_VERBS = %w{GET POST PUT PATCH DELETE HEAD OPTIONS TRACE}

module Lotus
  class Router < HttpRouter
    VERSION = '0.0.1'

    attr_reader :resolver

    def self.draw(options = {}, &blk)
      new(options).tap {|r| r.instance_eval(&blk) }
    end

    def initialize(options = {})
      super

      @default_scheme = options[:scheme]   if options[:scheme]
      @default_host   = options[:host]     if options[:host]
      @default_port   = options[:port]     if options[:port]
      @resolver       = options[:resolver] || Routing::EndpointResolver.new
      @route_class    = options[:route]    || Routing::Route
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

    def reset! #:api: private
      uncompile
      @routes, @named_routes, @root = [], Hash.new{|h,k| h[k] = []}, Node::Root.new(self)
      @default_host, @default_port, @default_scheme = 'localhost', 80, 'http'
    end

    def pass_on_response(response) #:api: private
      super response.to_a
    end

    def no_response(request, env) #:api: private
      if request.acceptable_methods.any? && !request.acceptable_methods.include?(env['REQUEST_METHOD'])
        [405, {'Allow' => request.acceptable_methods.sort.join(", ")}, []]
      else
        @default_app.call(env)
      end
    end

    private
    def add_with_request_method(path, method, opts = {}, &app)
      super.generate(resolver, opts, &app)
    end
  end
end
