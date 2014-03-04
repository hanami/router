module Lotus
  module Routing
    class RouteSet
      REQUEST_METHOD = 'REQUEST_METHOD'.freeze
      PATH_INFO = 'PATH_INFO'.freeze
      ROUTER_PARAMS = 'router.params'.freeze

      attr_reader :routes

      def initialize
        @routes = {
          'get' => {},
          'head' => {},
          'post' => {},
          'put' => {},
          'patch' => {},
          'delete' => {},
          'trace' => {},
          'options' => {}
        }
      end

      def call(env)
        @routes.freeze
        env[ROUTER_PARAMS] ||= {}
        endpoint = @routes[env[REQUEST_METHOD].downcase][env[PATH_INFO]]
        endpoint.call(env) if endpoint
      end

      def add(route)
        route._verbs.each do |verb|
          add_with_verb(verb, route)
        end
      end

      private
      def add_with_verb(verb, route)
        @routes[verb.to_s].store(route._path, route._endpoint)
      end
    end
  end
end
