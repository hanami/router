require 'lotus/utils/path_prefix'

module Lotus
  module Routing
    # Routes inspector
    #
    # @since 0.2.0
    class RoutesInspector
      # Default route formatter
      #
      # @since 0.2.0
      # @api private
      FORMATTER = "%<name>20s %<methods>-10s %<path>-30s %<endpoint>-30s\n".freeze

      # Default HTTP methods separator
      #
      # @since 0.2.0
      # @api private
      HTTP_METHODS_SEPARATOR = ', '.freeze

      # Default inspector header hash values
      #
      # @since 0.5.0
      # @api private
      INSPECTOR_HEADER_HASH =  Hash[
        name:     'Name',
        methods:  'Method',
        path:     'Path',
        endpoint: 'Action'
      ].freeze

      # Default inspector header name values
      #
      # @since 0.5.0
      # @api private
      INSPECTOR_HEADER_NAME = 'Name'.freeze

      # Empty line string
      #
      # @since 0.5.0
      # @api private
      EMPTY_LINE = "\n".freeze

      # Instantiate a new inspector
      #
      # @return [Lotus::Routing::RoutesInspector] the new instance
      #
      # @since 0.2.0
      # @api private
      def initialize(routes)
        @routes = routes
      end

      # Return a formatted string that describes all the routes
      #
      # @param formatter [String] the optional formatter for a route
      # @param base_path [String] the base path of a nested route
      #
      # @return [String] routes pretty print
      #
      # @since 0.2.0
      #
      # @see Lotus::Routing::RoutesInspector::FORMATTER
      #
      # @example Default formatter
      #   require 'lotus/router'
      #
      #   router = Lotus::Router.new do
      #     get    '/',       to: 'home#index'
      #     get    '/login',  to: 'sessions#new',     as: :login
      #     post   '/login',  to: 'sessions#create'
      #     delete '/logout', to: 'sessions#destroy', as: :logout
      #   end
      #
      #   puts router.inspector.to_s
      #     # =>   Name Method     Path                     Action
      #
      #                 GET, HEAD  /                        Home::Index
      #           login GET, HEAD  /login                   Sessions::New
      #                 POST       /login                   Sessions::Create
      #          logout GET, HEAD  /logout                  Sessions::Destroy
      #
      # @example Custom formatter
      #   require 'lotus/router'
      #
      #   router = Lotus::Router.new do
      #     get    '/',       to: 'home#index'
      #     get    '/login',  to: 'sessions#new',     as: :login
      #     post   '/login',  to: 'sessions#create'
      #     delete '/logout', to: 'sessions#destroy', as: :logout
      #   end
      #
      #   formatter = "| %{methods} | %{name} | %{path} | %{endpoint} |\n"
      #
      #   puts router.inspector.to_s(formatter)
      #     # => | Method    | Name   | Path    | Action            |
      #
      #          | GET, HEAD |        | /       | Home::Index       |
      #          | GET, HEAD | login  | /login  | Sessions::New     |
      #          | POST      |        | /login  | Sessions::Create  |
      #          | GET, HEAD | logout | /logout | Sessions::Destroy |
      #
      # @example Nested routes
      #   require 'lotus/router'
      #
      #   class AdminLotusApp
      #     def call(env)
      #     end
      #     def routes
      #       Lotus::Router.new {
      #         get '/home', to: 'home#index'
      #       }
      #     end
      #   end
      #
      #   router = Lotus::Router.new {
      #     get '/fakeroute', to: 'fake#index'
      #     mount AdminLotusApp, at: '/admin'
      #     mount Lotus::Router.new {
      #       get '/posts', to: 'posts#index'
      #       mount Lotus::Router.new {
      #         get '/comments', to: 'comments#index'
      #       }, at: '/second_mount'
      #     }, at: '/api'
      #   }
      #
      #   formatter = "| %{methods} | %{name} | %{path} | %{endpoint} |\n"
      #
      #   puts router.inspector.to_s(formatter)
      #     # => | Method    | Name | Path                       | Action          |
      #
      #          | GET, HEAD |      | /fakeroute                 | Fake::Index     |
      #          | GET, HEAD |      | /admin/home                | Home::Index     |
      #          | GET, HEAD |      | /api/posts                 | Posts::Index    |
      #          | GET, HEAD |      | /api/second_mount/comments | Comments::Index |
      def to_s(formatter = FORMATTER, base_path = nil)
        base_path = Utils::PathPrefix.new(base_path)

        inspect_routes(formatter, base_path)
          .insert(0, formatter % INSPECTOR_HEADER_HASH + EMPTY_LINE)
      end

      # Returns a string representation of routes
      #
      # @param formatter [String] the template for the output
      # @param base_path [Lotus::Utils::PathPrefix] the base path
      #
      # @return [String] serialized routes from router
      #
      # @since 0.2.0
      # @api private
      #
      # @see Lotus::Routing::RoutesInspector#FORMATTER
      # @see Lotus::Routing::RoutesInspector#to_s
      def inspect_routes(formatter, base_path)
        result = ''

        # TODO refactoring: replace conditional with polymorphism
        # We're exposing too much knowledge from Routing::Route:
        # #path_for_generation and #base_path
        @routes.each do |route|
          result << if router = route.nested_router
            inspect_router(formatter, router, route, base_path)
          else
            inspect_route(formatter, route, base_path)
          end
        end

        result
      end

      private

      # Returns a string representation of the given route
      #
      # @param formatter [String] the template for the output
      # @param route [Lotus::Routing::Route] a route
      # @param base_path [Lotus::Utils::PathPrefix] the base path
      #
      # @return [String] serialized route
      #
      # @since 0.2.0
      # @api private
      #
      # @see Lotus::Routing::RoutesInspector#FORMATTER
      # @see Lotus::Routing::RoutesInspector#to_s
      def inspect_route(formatter, route, base_path)
        formatter % Hash[
          name:     route.name,
          methods:  route.request_methods.to_a.join(HTTP_METHODS_SEPARATOR),
          path:     base_path.join(route.path_for_generation),
          endpoint: route.dest.inspect
        ]
      end

      # Returns a string representation of the given router
      #
      # @param formatter [String] the template for the output
      # @param router [Lotus::Router] a router
      # @param route [Lotus::Routing::Route] a route
      # @param base_path [Lotus::Utils::PathPrefix] the base path
      #
      # @return [String] serialized routes from router
      #
      # @since 0.2.0
      # @api private
      #
      # @see Lotus::Routing::RoutesInspector#FORMATTER
      # @see Lotus::Routing::RoutesInspector#to_s
      def inspect_router(formatter, router, route, base_path)
        router.inspector.inspect_routes(formatter, base_path.join(route.path_for_generation))
      end
    end
  end
end
