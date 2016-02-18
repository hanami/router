require 'http_router/route'

module Hanami
  module Routing
    # Entry of the routing system
    #
    # @api private
    #
    # @since 0.1.0
    #
    # @see http://rdoc.info/gems/http_router/HttpRouter/Route
    #
    # @example
    #   require 'hanami/router'
    #
    #   router = Hanami::Router.new
    #   router.get('/', to: endpoint) # => #<Hanami::Routing::Route:0x007f83083ba028 ...>
    class Route < HttpRouter::Route
      # Asks the given resolver to return an endpoint that will be associated
      #   with the other options.
      #
      # @param resolver [Hanami::Routing::EndpointResolver, #resolve] this may change
      #   according to the :resolve option passed to Hanami::Router#initialize.
      #
      # @param options [Hash] options to customize the route
      # @option options [Symbol] :as the name we want to use for the route
      #
      # @since 0.1.0
      #
      # @api private
      #
      # @see Hanami::Router#initialize
      #
      # @example
      #   require 'hanami/router'
      #
      #   router = Hanami::Router.new
      #   router.get('/', to: endpoint, as: :home_page).name # => :home_page
      #
      #   router.path(:home_page) # => '/'
      def generate(resolver, options = {}, &endpoint)
        self.to   = resolver.resolve(options, &endpoint)
        self.name = options[:as].to_sym if options[:as]
        self
      end

      # Introspect the given route to understand if there is a wrapped
      # router that has an inspector
      #
      # @since 0.2.0
      # @api private
      def nested_router
        dest.routes if dest.respond_to?(:routes) && dest.routes.respond_to?(:inspector)
      end

      private
      def to=(dest = nil, &blk)
        self.to dest, &blk
      end
    end
  end
end
