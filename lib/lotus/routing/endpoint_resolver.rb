require 'lotus/utils/string'
require 'lotus/utils/class'
require 'lotus/routing/endpoint'

module Lotus
  module Routing
    # Resolve duck-typed endpoints
    #
    # @since 0.1.0
    #
    # @api private
    class EndpointResolver
      # Default suffix appended to the controller#action string.
      # A different suffix can be passed to #initialize with the `:suffix` option.
      #
      # @see #initialize
      # @see #resolve
      #
      # @since 0.1.0
      #
      # @example
      #   require 'lotus/router'
      #
      #   router = Lotus::Router.new do
      #     get '/', to: 'articles#show'
      #   end
      #
      #   # That string is transformed into "Articles(::Controller::|Controller::)Show"
      #   # because the resolver is able to lookup (in the given order) for:
      #   #
      #   #  * Articles::Controller::Show
      #   #  * ArticlesController::Show
      #   #
      #   # When it finds a class, it stops the lookup and returns the result.
      SUFFIX = '(::Controller::|Controller::)'.freeze

      # Default separator for controller and action.
      # A different separator can be passed to #initialize with the `:separator` option.
      #
      # @see #initialize
      # @see #resolve
      #
      # @since 0.1.0
      #
      # @example
      #   require 'lotus/router'
      #
      #   router = Lotus::Router.new do
      #     get '/', to: 'articles#show'
      #   end
      ACTION_SEPARATOR = '#'.freeze

      attr_reader :action_separator

      # Initialize an endpoint resolver
      #
      # @param options [Hash] the options used to customize lookup behavior
      #
      # @option options [Class] :endpoint the endpoint class that is returned
      #   by `#resolve`. (defaults to `Lotus::Routing::Endpoint`)
      #
      # @option options [Class,Module] :namespace the Ruby namespace where to
      #   lookup for controllers and actions. (defaults to `Object`)
      #
      # @option options [String] :suffix the suffix appended to the controller
      #   name during the lookup. (defaults to `SUFFIX`)
      #
      # @option options [String] :action_separator the sepatator between controller and
      #   action name. (defaults to `ACTION_SEPARATOR`)
      #
      #
      #
      # @return [Lotus::Routing::EndpointResolver] self
      #
      #
      #
      # @since 0.1.0
      #
      #
      #
      # @example Specify custom endpoint class
      #   require 'lotus/router'
      #
      #   resolver = Lotus::Routing::EndpointResolver.new(endpoint: CustomEndpoint)
      #   router   = Lotus::Router.new(resolver: resolver)
      #
      #   router.get('/', to: endpoint).dest # => #<CustomEndpoint:0x007f97f3359570 ...>
      #
      #
      #
      # @example Specify custom Ruby namespace
      #   require 'lotus/router'
      #
      #   resolver = Lotus::Routing::EndpointResolver.new(namespace: MyApp)
      #   router   = Lotus::Router.new(resolver: resolver)
      #
      #   router.get('/', to: 'articles#show')
      #   # => Will look for:
      #   #  * MyApp::Articles::Controller::Show
      #   #  * MyApp::ArticlesController::Show
      #
      #
      #
      # @example Specify custom controller suffix
      #   require 'lotus/router'
      #
      #   resolver = Lotus::Routing::EndpointResolver.new(suffix: '(Controller::|Ctrl::)')
      #   router   = Lotus::Router.new(resolver: resolver)
      #
      #   router.get('/', to: 'articles#show')
      #   # => Will look for:
      #   #  * ArticlesController::Show
      #   #  * ArticlesCtrl::Show
      #
      #
      #
      # @example Specify custom controller-action separator
      #   require 'lotus/router'
      #
      #   resolver = Lotus::Routing::EndpointResolver.new(separator: '@')
      #   router   = Lotus::Router.new(resolver: resolver)
      #
      #   router.get('/', to: 'articles@show')
      #   # => Will look for:
      #   #  * Articles::Controller::Show
      #   #  * ArticlesController::Show
      def initialize(options = {})
        @endpoint_class   = options[:endpoint]         || Endpoint
        @namespace        = options[:namespace]        || Object
        @suffix           = options[:suffix]           || SUFFIX
        @action_separator = options[:action_separator] || ACTION_SEPARATOR
      end

      # Resolve the given set of HTTP verb, path, endpoint and options.
      # If it fails to resolve, it will mount the default endpoint to the given
      # path, which returns an 404 (Not Found).
      #
      # @param options [Hash] the options required to resolve the endpoint
      #
      # @option options [String,Proc,Class,Object#call] :to the endpoint
      # @option options [String] :prefix an optional path prefix
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
      #   require 'lotus/router'
      #
      #   router = Lotus::Router.new
      #   router.get '/', to: ->(env) { [200, {}, ['Hi!']] }
      #
      # @example Resolve to a class
      #   require 'lotus/router'
      #
      #   router = Lotus::Router.new
      #   router.get '/', to: RackMiddleware
      #
      # @example Resolve to a Rack compatible object (respond to #call)
      #   require 'lotus/router'
      #
      #   router = Lotus::Router.new
      #   router.get '/', to: AnotherMiddleware.new
      #
      # @example Resolve to a Lotus::Action from a string (see Lotus::Controller framework)
      #   require 'lotus/router'
      #
      #   router = Lotus::Router.new
      #   router.get '/', to: 'articles#show'
      #
      # @example Resolve to a Lotus::Action (see Lotus::Controller framework)
      #   require 'lotus/router'
      #
      #   router = Lotus::Router.new
      #   router.get '/', to: ArticlesController::Show
      #
      # @example Resolve with a path prefix
      #   require 'lotus/router'
      #
      #   router = Lotus::Router.new
      #   router.get '/dashboard', to: BackendApp.new, prefix: 'backend'
      #     # => Will be available under '/backend/dashboard'
      def resolve(options, &endpoint)
        result = endpoint || find(options)
        resolve_callable(result) || resolve_matchable(result) || default
      end

      def _resolve(options, &endpoint)
        result = endpoint || find(options)
        resolve_callable(result) || resolve_matchable(result)
      end

      # Finds a path from the given options.
      #
      # @param options [Hash] the path description
      # @option options [String,Proc,Class,Object#call] :to the endpoint
      # @option options [String] :prefix an optional path prefix
      #
      # @since 0.1.0
      #
      # @return [Object]
      def find(options)
        if prefix = options[:prefix]
          prefix.join(options[:to])
        else
          options[:to]
        end
      end

      protected
      def default
        @endpoint_class.new(
          ->(env) { [404, {'X-Cascade' => 'pass'}, 'Not Found'] }
        )
      end

      def constantize(string)
        begin
          ClassEndpoint.new(Utils::Class.load!(string, @namespace))
        rescue NameError
          LazyEndpoint.new(string, @namespace)
        end
      end

      def classify(string)
        Utils::String.new(string).classify
      end

      private
      def resolve_callable(callable)
        if callable.respond_to?(:call)
          @endpoint_class.new(callable)
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
          controller + @suffix + action
        end
      end
    end
  end
end
