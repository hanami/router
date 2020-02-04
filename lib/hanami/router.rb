# frozen_string_literal: true

module Hanami
  # Rack compatible, lightweight and fast HTTP Router.
  #
  # @since 0.1.0
  #
  # rubocop:disable Metrics/ClassLength
  class Router
    require "hanami/router/version"
    require "hanami/router/error"
    require "hanami/router/inner"
    require "hanami/router/middleware"

    def self.define(&blk)
      blk
    end

    def initialize(base_url: DEFAULT_BASE_URL, prefix: DEFAULT_PREFIX, resolver: DEFAULT_RESOLVER, block_context: nil, &blk)
      @inner = Inner.new(base_url, prefix, resolver, block_context)
      @stack = Middleware::Stack.new
      instance_eval(&blk)
      freeze
    end

    def freeze
      @app = @stack.finalize(inner)
      @app.freeze
      remove_instance_variable(:@stack)
      super
    end

    def call(env)
      @app.call(env)
    end

    def root(to: nil, &blk)
      get("/", to: to, as: :root, &blk)
    end

    def get(path, to: nil, as: nil, **constraints, &blk)
      add_route("GET", path, to, as, constraints, &blk)
      add_route("HEAD", path, to, as, constraints, &blk)
    end

    def post(path, to: nil, as: nil, **constraints, &blk)
      add_route("POST", path, to, as, constraints, &blk)
    end

    def patch(path, to: nil, as: nil, **constraints, &blk)
      add_route("PATCH", path, to, as, constraints, &blk)
    end

    def put(path, to: nil, as: nil, **constraints, &blk)
      add_route("PUT", path, to, as, constraints, &blk)
    end

    def delete(path, to: nil, as: nil, **constraints, &blk)
      add_route("DELETE", path, to, as, constraints, &blk)
    end

    def trace(path, to: nil, as: nil, **constraints, &blk)
      add_route("TRACE", path, to, as, constraints, &blk)
    end

    def options(path, to: nil, as: nil, **constraints, &blk)
      add_route("OPTIONS", path, to, as, constraints, &blk)
    end

    def link(path, to: nil, as: nil, **constraints, &blk)
      add_route("LINK", path, to, as, constraints, &blk)
    end

    def unlink(path, to: nil, as: nil, **constraints, &blk)
      add_route("UNLINK", path, to, as, constraints, &blk)
    end

    def redirect(path, to:, as: nil, code: DEFAULT_REDIRECT_CODE)
      inner.redirect(path, to: to, as: as, code: code)
    end

    def scope(path, &blk)
      stack.with(path) do
        inner.scope(path) do
          instance_eval(&blk)
        end
      end
    end

    def use(middleware, *args, &blk)
      stack.use(middleware, args, &blk)
    end

    def mount(app, at:, **constraints)
      inner.mount(app, at: at, **constraints)
    end

    def path(name, variables = {})
      inner.path(name, variables)
    end

    def url(name, variables = {})
      inner.url(name, variables)
    end

    def recognize(env, params = {}, options = {})
      require "hanami/router/recognized_route"
      env = env_for(env, params, options)
      endpoint, params = inner.lookup(env)

      RecognizedRoute.new(
        endpoint, Params.call(env, params)
      )
    end

    protected

    # Fabricate Rack env for the given Rack env, path or named route
    #
    # @param env [Hash, String, Symbol] Rack env, path or route name
    # @param options [Hash] a set of options for Rack env or route params
    # @param params [Hash] a set of params
    #
    # @return [Hash] Rack env
    #
    # @since 0.5.0
    # @api private
    #
    # @see Hanami::Router#recognize
    # @see http://www.rubydoc.info/github/rack/rack/Rack%2FMockRequest.env_for
    def env_for(env, params = {}, options = {}) # rubocop:disable Metrics/MethodLength
      require "rack/mock"

      case env
      when ::String
        ::Rack::MockRequest.env_for(env, options)
      when ::Symbol
        begin
          url = path(env, params)
          return env_for(url, params, options) # rubocop:disable Style/RedundantReturn
        rescue Hanami::Router::InvalidRouteException
          EMPTY_RACK_ENV.dup
        end
      else
        env
      end
    end

    private

    DEFAULT_BASE_URL = "http://localhost"
    DEFAULT_PREFIX = "/"
    DEFAULT_RESOLVER = ->(_, to) { to }
    DEFAULT_REDIRECT_CODE = 301

    EMPTY_RACK_ENV = {}.freeze

    attr_reader :inner, :stack

    def add_route(http_method, path, to, as, constraints, &blk)
      inner.add_route(http_method, path, to, as, constraints, &blk)
    end
  end
end
# rubocop:enable Metrics/ClassLength
