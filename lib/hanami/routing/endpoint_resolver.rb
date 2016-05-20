require 'hanami/utils/string'
require 'hanami/utils/class'
require 'hanami/routing/endpoint'

module Hanami
  module Routing
    # Resolve duck-typed endpoints
    #
    # @since 0.1.0
    #
    # @api private
    class EndpointResolver
      # @since 0.2.0
      # @api private
      NAMING_PATTERN = '%{controller}::%{action}'.freeze

      # @since x.x.x
      # @api private
      DEFAULT_RESPONSE = [404, {'X-Cascade' => 'pass'}, 'Not Found'].freeze

      # Default separator for controller and action.
      # A different separator can be passed to #initialize with the `:separator` option.
      #
      # @see #initialize
      # @see #resolve
      #
      # @since 0.1.0
      #
      # @example
      #   require 'hanami/router'
      #
      #   router = Hanami::Router.new do
      #     get '/', to: 'articles#show'
      #   end
      ACTION_SEPARATOR = '#'.freeze

      attr_reader :action_separator

      # Initialize an endpoint resolver
      #
      # @param options [Hash] the options used to customize lookup behavior
      #
      # @option options [Class] :endpoint the endpoint class that is returned
      #   by `#resolve`. (defaults to `Hanami::Routing::Endpoint`)
      #
      # @option options [Class,Module] :namespace the Ruby namespace where to
      #   lookup for controllers and actions. (defaults to `Object`)
      #
      # @option options [String] :pattern the string to interpolate in order
      #   to return an action name. This string SHOULD contain
      #   <tt>'%{controller}'</tt> and <tt>'%{action}'</tt>, all the other keys
      #   will be ignored.
      #   See the examples below.
      #
      # @option options [String] :action_separator the sepatator between controller and
      #   action name. (defaults to `ACTION_SEPARATOR`)
      #
      # @return [Hanami::Routing::EndpointResolver] self
      #
      # @since 0.1.0
      #
      # @example Specify custom endpoint class
      #   require 'hanami/router'
      #
      #   resolver = Hanami::Routing::EndpointResolver.new(endpoint: CustomEndpoint)
      #   router   = Hanami::Router.new(resolver: resolver)
      #
      #   router.get('/', to: endpoint).dest # => #<CustomEndpoint:0x007f97f3359570 ...>
      #
      # @example Specify custom Ruby namespace
      #   require 'hanami/router'
      #
      #   resolver = Hanami::Routing::EndpointResolver.new(namespace: MyApp)
      #   router   = Hanami::Router.new(resolver: resolver)
      #
      #   router.get('/', to: 'articles#show')
      #     # => Will look for: MyApp::Articles::Show
      #
      #
      #
      # @example Specify custom pattern
      #   require 'hanami/router'
      #
      #   resolver = Hanami::Routing::EndpointResolver.new(pattern: '%{controller}Controller::%{action}')
      #   router   = Hanami::Router.new(resolver: resolver)
      #
      #   router.get('/', to: 'articles#show')
      #     # => Will look for: ArticlesController::Show
      #
      #
      #
      # @example Specify custom controller-action separator
      #   require 'hanami/router'
      #
      #   resolver = Hanami::Routing::EndpointResolver.new(separator: '@')
      #   router   = Hanami::Router.new(resolver: resolver)
      #
      #   router.get('/', to: 'articles@show')
      #     # => Will look for: Articles::Show
      def initialize(options = {})
        @endpoint_class   = options[:endpoint]         || Endpoint
        @namespace        = options[:namespace]        || Object
        @action_separator = options[:action_separator] || ACTION_SEPARATOR
        @pattern          = options[:pattern]          || NAMING_PATTERN
      end

      # Resolve the given set of HTTP verb, path, endpoint and options.
      # If it fails to resolve, it will mount the default endpoint to the given
      # path, which returns an 404 (Not Found).
      #
      # @param options [Hash] the options required to resolve the endpoint
      #
      # @option options [String,Proc,Class,Object#call] :to the endpoint
      # @option options [String] :namespace an optional routing namespace
      #
      # @return [Endpoint] this may vary according to the :endpoint option
      #   passed to #initialize
      #
      # @since 0.1.0
      #
      # @see #initialize
      # @see #find
      #
      # @example Resolve to a Proc
      #   require 'hanami/router'
      #
      #   router = Hanami::Router.new
      #   router.get '/', to: ->(env) { [200, {}, ['Hi!']] }
      #
      # @example Resolve to a class
      #   require 'hanami/router'
      #
      #   router = Hanami::Router.new
      #   router.get '/', to: RackMiddleware
      #
      # @example Resolve to a Rack compatible object (respond to #call)
      #   require 'hanami/router'
      #
      #   router = Hanami::Router.new
      #   router.get '/', to: AnotherMiddleware.new
      #
      # @example Resolve to a Hanami::Action from a string (see Hanami::Controller framework)
      #   require 'hanami/router'
      #
      #   router = Hanami::Router.new
      #   router.get '/', to: 'articles#show'
      #
      # @example Resolve to a Hanami::Action (see Hanami::Controller framework)
      #   require 'hanami/router'
      #
      #   router = Hanami::Router.new
      #   router.get '/', to: Articles::Show
      #
      # @example Resolve a redirect with a namespace
      #   require 'hanami/router'
      #
      #   router = Hanami::Router.new
      #   router.namespace 'users' do
      #     get '/home',           to: ->(env) { ... }
      #     redirect '/dashboard', to: '/home'
      #   end
      #
      #   # GET /users/dashboard => 301 Location: "/users/home"
      def resolve(options, &endpoint)
        result = endpoint || find(options)
        resolve_callable(result) || resolve_matchable(result) || default
      end

      # Finds a path from the given options.
      #
      # @param options [Hash] the path description
      # @option options [String,Proc,Class,Object#call] :to the endpoint
      # @option options [String] :namespace an optional namespace
      #
      # @since 0.1.0
      #
      # @return [Object]
      def find(options)
        options[:to]
      end

      protected
      def default
        @endpoint_class.new(
          ->(env) { DEFAULT_RESPONSE }
        )
      end

      def constantize(string)
        klass = Utils::Class.load!(string, @namespace)
        if klass.respond_to?(:call)
          Endpoint.new(klass)
        else
          ClassEndpoint.new(klass)
        end
      rescue NameError
        LazyEndpoint.new(string, @namespace)
      end

      def classify(string)
        Utils::String.new(string).classify
      end

      private
      def resolve_callable(callable)
        if callable.respond_to?(:call)
          @endpoint_class.new(callable)
        elsif callable.is_a?(Class) && callable.instance_methods.include?(:call)
          @endpoint_class.new(callable.new)
        end
      end

      def resolve_matchable(matchable)
        if matchable.respond_to?(:match)
          constantize(
            resolve_action(matchable) || classify(matchable)
          )
        end
      end

      def resolve_action(string)
        if string.match(action_separator)
          controller, action = string.split(action_separator).map {|token| classify(token) }
          @pattern % {controller: controller, action: action}
        end
      end
    end
  end
end
