# frozen_string_literal: true

require "hanami/router/error"
require "hanami/router/prefix"
require "hanami/router/segment"
require "hanami/router/params"
require "hanami/router/redirect"
require "hanami/router/prefix"
require "hanami/router/trie"
require "rack/utils"

module Hanami
  class Router
    # Inner router
    class Inner # rubocop:disable Metrics/ClassLength
      def initialize(base_url, prefix, resolver)
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
      end

      def call(env)
        endpoint, params = lookup(env)

        unless endpoint
          return not_allowed(env) ||
                 not_found
        end

        endpoint.call(
          Params.call(env, params)
        ).to_a
      end

      def lookup(env)
        endpoint = fixed(env)
        return [endpoint, EMPTY_PARAMS] if endpoint

        variable(env) || globbed(env) || mounted(env)
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def add_route(http_method, path, to, as, constraints)
        path = prefixed_path(path)
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

        @named[prefixed_name(as)] = Segment.fabricate(path, **constraints) if as
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize

      def redirect(path, to:, as:, code:)
        body = Rack::Utils::HTTP_STATUS_CODES.fetch(code) do
          raise UnknownHTTPStatusCodeError.new(code)
        end

        destination = prefixed_path(to)
        endpoint = Redirect.new(destination, ->(*) { [code, { "Location" => destination }, [body]] })

        add_route("GET", path, endpoint, as, code)
      end

      def scope(path)
        path_prefix = @path_prefix
        name_prefix = @name_prefix

        begin
          @path_prefix = @path_prefix.join(path.to_s)
          @name_prefix = @name_prefix.join(path.to_s)
          yield
        ensure
          @path_prefix = path_prefix
          @name_prefix = name_prefix
        end
      end

      def mount(app, at:, **constraints)
        path = prefixed_path(at)
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

      private

      EMPTY_PARAMS = {}.freeze

      NOT_FOUND = [404, { "Content-Length" => "9" }, ["Not Found"]].freeze
      NOT_ALLOWED = [405, { "Content-Length" => "11" }, ["Not Allowed"]].freeze

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
        (not_allowed_fixed(env) || not_allowed_variable(env)) and return NOT_ALLOWED
      end

      def not_found
        NOT_FOUND
      end

      def not_allowed_fixed(env)
        found = false

        @fixed.each_value do |routes|
          break if found

          found = routes.key?(env["PATH_INFO"])
        end

        found
      end

      def not_allowed_variable(env)
        found = false

        @variable.each_value do |routes|
          break if found

          found = routes.find(env["PATH_INFO"])
        end

        found
      end

      def variable?(path)
        /:/.match?(path)
      end

      def globbed?(path)
        /\*/.match?(path)
      end

      def prefixed_path(path)
        @path_prefix.join(path).to_s
      end

      def prefixed_name(name)
        @name_prefix.relative_join(name, "_").to_sym
      end
    end
  end
end
