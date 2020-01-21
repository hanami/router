# frozen_string_literal: true

require "rack/utils"

module Hanami
  # Rack compatible, lightweight and fast HTTP Router.
  #
  # @since 0.1.0
  class Router # rubocop:disable Metrics/ClassLength
    require "hanami/router/version"
    require "hanami/router/error"
    require "hanami/router/segment"
    require "hanami/router/redirect"
    require "hanami/router/prefix"
    require "hanami/router/params"
    require "hanami/router/trie"

    def self.define(&blk)
      blk
    end

    def initialize(base_url: DEFAULT_BASE_URL, prefix: DEFAULT_PREFIX, resolver: DEFAULT_RESOLVER, &blk)
      @base_url = base_url
      # TODO: verify if Prefix can handle both name and path prefix
      @path_prefix = Prefix.new(prefix)
      @name_prefix = Prefix.new("")
      @resolver = resolver
      @fixed = {}
      @variable = {}
      @globbed = {}
      @mounted = {}
      @named = {}
      instance_eval(&blk)
    end

    def call(env)
      endpoint, params = lookup(env)

      unless endpoint
        return not_allowed(env) ||
               not_found
      end

      endpoint.call(
        _params(env, params)
      ).to_a
    end

    def root(to:)
      get("/", to: to, as: :root)
    end

    def get(path, to:, as: nil, **constraints)
      add_route("GET", path, to, as, constraints)
      add_route("HEAD", path, to, as, constraints)
    end

    def post(path, to:, as: nil, **constraints)
      add_route("POST", path, to, as, constraints)
    end

    def patch(path, to:, as: nil, **constraints)
      add_route("PATCH", path, to, as, constraints)
    end

    def put(path, to:, as: nil, **constraints)
      add_route("PUT", path, to, as, constraints)
    end

    def delete(path, to:, as: nil, **constraints)
      add_route("DELETE", path, to, as, constraints)
    end

    def trace(path, to:, as: nil, **constraints)
      add_route("TRACE", path, to, as, constraints)
    end

    def options(path, to:, as: nil, **constraints)
      add_route("OPTIONS", path, to, as, constraints)
    end

    def link(path, to:, as: nil, **constraints)
      add_route("LINK", path, to, as, constraints)
    end

    def unlink(path, to:, as: nil, **constraints)
      add_route("UNLINK", path, to, as, constraints)
    end

    def redirect(path, to:, as: nil, code: DEFAULT_REDIRECT_CODE)
      get(path, to: _redirect(to, code), as: as)
    end

    def scope(path, &blk)
      path_prefix = @path_prefix
      name_prefix = @name_prefix

      begin
        @path_prefix = @path_prefix.join(path.to_s)
        @name_prefix = @name_prefix.join(path.to_s)
        instance_eval(&blk)
      ensure
        @path_prefix = path_prefix
        @name_prefix = name_prefix
      end
    end

    def mount(app, at:, **constraints)
      path = _prefixed_path(at)
      prefix = Segment.fabricate(path, **constraints)
      @mounted[prefix] = @resolver.call(path, app)
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

    def recognize(env, params = {}, options = {})
      require "hanami/router/recognized_route"
      env = env_for(env, params, options)
      endpoint, params = lookup(env)

      RecognizedRoute.new(
        endpoint, _params(env, params)
      )
    end

    def fixed(env)
      @fixed.dig(env["REQUEST_METHOD"], env["PATH_INFO"])
    end

    def variable(env)
      @variable[env["REQUEST_METHOD"]]&.find(env["PATH_INFO"])
    end

    def globbed(env)
      @globbed[env["REQUEST_METHOD"]]&.each do |path, to|
        if (match = path.match(env["PATH_INFO"]))
          return [to, match.named_captures]
        end
      end

      nil
    end

    def mounted(env)
      @mounted.each do |prefix, app|
        next unless (match = prefix.peek_match(env["PATH_INFO"]))

        # TODO: ensure compatibility with existing env["SCRIPT_NAME"]
        # TODO: cleanup this code
        env["SCRIPT_NAME"] = env["SCRIPT_NAME"].to_s + prefix.to_s
        env["PATH_INFO"] = env["PATH_INFO"].sub(prefix.to_s, "")
        env["PATH_INFO"] = "/" if env["PATH_INFO"] == ""

        return [app, match.named_captures]
      end

      nil
    end

    def not_allowed(env)
      (_not_allowed_fixed(env) || _not_allowed_variable(env)) and return NOT_ALLOWED
    end

    def not_found
      NOT_FOUND
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

    NOT_FOUND = [404, { "Content-Length" => "9" }, ["Not Found"]].freeze
    NOT_ALLOWED = [405, { "Content-Length" => "11" }, ["Not Allowed"]].freeze

    PARAMS = "router.params"
    EMPTY_PARAMS = {}.freeze
    EMPTY_RACK_ENV = {}.freeze

    def lookup(env)
      endpoint = fixed(env)
      return [endpoint, EMPTY_PARAMS] if endpoint

      variable(env) || globbed(env) || mounted(env)
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def add_route(http_method, path, to, as, constraints)
      path = _prefixed_path(path)
      to = @resolver.call(path, to)

      if globbed?(path)
        @globbed[http_method] ||= []
        @globbed[http_method] << [Segment.fabricate(path, **constraints), to]
      elsif variable?(path)
        @variable[http_method] ||= Trie.new
        @variable[http_method].add(path, to, constraints)
      else
        @fixed[http_method] ||= {}
        @fixed[http_method][path] = to
      end

      @named[_prefixed_name(as)] = Segment.fabricate(path, **constraints) if as
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    # def add_route(http_method, path, to, as, constraints, &blk)
    #   (to || blk) or raise "missing endpoint"
    #   to = Block.new(blk) if to.nil?

    #   path = _prefixed_path(path)

    #   if variable?(path)
    #     @variable[http_method] ||= Trie.new
    #     @variable[http_method].add(path, to, constraints)
    #   else
    #     @fixed[http_method] ||= {}
    #     @fixed[http_method][path] = to
    #   end

    #   # FIXME: pass constraints
    #   @named[_prefixed_name(as)] = Segment.fabricate(path, {}) if as
    # end

    def variable?(path)
      /:/.match?(path)
    end

    def globbed?(path)
      /\*/.match?(path)
    end

    def _prefixed_path(path)
      @path_prefix.join(path).to_s
    end

    def _prefixed_name(name)
      @name_prefix.relative_join(name, "_").to_sym
    end

    def _redirect(to, code)
      body = Rack::Utils::HTTP_STATUS_CODES.fetch(code) do
        raise UnknownHTTPStatusCodeError.new(code)
      end

      destination = _prefixed_path(to)
      Redirect.new(destination, ->(*) { [code, { "Location" => destination }, [body]] })
    end

    def _params(env, params)
      params ||= {}
      env[PARAMS] ||= {}
      env[PARAMS].merge!(Rack::Utils.parse_nested_query(env["QUERY_STRING"]))
      env[PARAMS].merge!(params)
      env[PARAMS] = Params.deep_symbolize(env[PARAMS])
      env
    end

    def _not_allowed_fixed(env)
      found = false

      @fixed.each_value do |routes|
        break if found

        found = routes.key?(env["PATH_INFO"])
      end

      found
    end

    def _not_allowed_variable(env)
      found = false

      @variable.each_value do |routes|
        break if found

        found = routes.find(env["PATH_INFO"])
      end

      found
    end
  end
end
