module Lotus
  module Routing
    # Routes inspector
    #
    # @since x.x.x
    class RoutesInspector
      # Default route formatter
      #
      # @since x.x.x
      # @api private
      FORMATTER = "%<name>20s %<methods>-10s %<path>-30s %<endpoint>-30s\n".freeze

      # Instantiate a new inspector
      #
      # @return [Lotus::Routing::RoutesInspector] the new instance
      #
      # @since x.x.x
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
      # @since x.x.x
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
      #     # =>        GET, HEAD  /                        Home::Index
      #          login  GET, HEAD  /login                   Sessions::New
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
      #     # => | GET, HEAD |        | /       | Home::Index       |
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
      #     # => | GET, HEAD |  | /fakeroute                 | Fake::Index     |
      #          | GET, HEAD |  | /admin/home                | Home::Index     |
      #          | GET, HEAD |  | /api/posts                 | Posts::Index    |
      #          | GET, HEAD |  | /api/second_mount/comments | Comments::Index |
      def to_s(formatter = FORMATTER, base_path = '')
        @routes.each_with_object("") do |route, result|
          destination = destination(route)
          result << if destination && destination.respond_to?(:routes)
            destination.routes.inspector.to_s(formatter, [base_path, route.path_for_generation].join)
          else
            formatter % inspect_route(route, base_path)
          end
        end
      end

      private

      def destination(route)
        route.dest.__getobj__ 
      rescue
        nil
      end

      # Return a Hash compatible with formatter
      #
      # @return [Hash] serialized route
      #
      # @since x.x.x
      # @api private
      #
      # @see Lotus::Routing::RoutesInspector#FORMATTER
      # @see Lotus::Routing::RoutesInspector#to_s
      def inspect_route(route, base_path = '')
        Hash[
          name:     route.name,
          methods:  route.request_methods.to_a.join(", "),
          path:     [base_path, route.original_path].join,
          endpoint: route.dest.inspect
        ]
      end
    end
  end
end
