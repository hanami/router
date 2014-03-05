module Lotus
  module Routing
    class RouteSet
      REQUEST_METHOD = 'REQUEST_METHOD'.freeze
      PATH_INFO = 'PATH_INFO'.freeze
      ROUTER_PARAMS = 'router.params'.freeze

      attr_reader :routes

      def initialize
        @routes = {
          'get' => { fixed: {}, wandering: {} },
          'head' => { fixed: {}, wandering: {} },
          'post' => { fixed: {}, wandering: {} },
          'put' => { fixed: {}, wandering: {} },
          'patch' => { fixed: {}, wandering: {} },
          'delete' => { fixed: {}, wandering: {} },
          'trace' => { fixed: {}, wandering: {} },
          'options' => { fixed: {}, wandering: {} }
        }
      end

      def call(env)
        @routes.freeze
        env[ROUTER_PARAMS] ||= {}

        if endpoint = match_fixed(env) || match_wandering(env)
          puts 'found'
          endpoint.call(env)
        end
      end

      def add(route)
        route._verbs.each do |verb|
          add_with_verb(verb, route)
        end
      end

      private
      def add_with_verb(verb, route)
        if route.fixed?
          @routes[verb.to_s][:fixed].store(route._path, route._endpoint)
        else
          #FIXME remove this condition once the refactoring will be done
          unless route._compiled_path.nil?
            @routes[verb.to_s][:wandering].store(route._compiled_path, route._endpoint)
          end
        end
      end

      def match_fixed(env)
        @routes[env[REQUEST_METHOD].downcase][:fixed][env[PATH_INFO]]
      end

      def match_wandering(env)
        match = nil
        route = @routes[env[REQUEST_METHOD].downcase][:wandering].find do |path,_|
          match = path.match(env[PATH_INFO])
        end

        if route
          route.first.names.each do |name|
            value = match[name]
            value = value.chop if value.match(/\.\z/)
            if value.match('/')
              value = value.split('/').reject {|e| e.nil? || e == '' }
            end
            env[ROUTER_PARAMS].merge!(name.to_sym => value) if value && value != ''
          end

          route.last
        end
      end
    end
  end
end
