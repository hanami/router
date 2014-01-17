require 'lotus/routing/http_router'
require 'lotus/routing/namespace'
require 'lotus/routing/resource'
require 'lotus/routing/resources'

module Lotus
  # Rack compatible, lightweight and fast HTTP Router.
  #
  # @since 0.1.0
  #
  # @example It offers an intuitive DSL, that supports most of the HTTP verbs:
  #   require 'lotus/router'
  #
  #   endpoint = ->(env) { [200, {}, ['Welcome to Lotus::Router!']] }
  #   router = Lotus::Router.new do
  #     get     '/', to: endpoint
  #     post    '/', to: endpoint
  #     put     '/', to: endpoint
  #     patch   '/', to: endpoint
  #     delete  '/', to: endpoint
  #     head    '/', to: endpoint
  #     options '/', to: endpoint
  #     trace   '/', to: endpoint
  #   end
  #
  #
  #
  # @example Specify an endpoint with `:to` (Rack compatible object)
  #   require 'lotus/router'
  #
  #   endpoint = ->(env) { [200, {}, ['Welcome to Lotus::Router!']] }
  #   router = Lotus::Router.new do
  #     get '/', to: endpoint
  #   end
  #
  #   # :to is mandatory for the default resolver (`Lotus::Routing::EndpointResolver.new`),
  #   # This behavior can be changed by passing a custom resolver to `Lotus::Router#initialize`
  #
  #
  #
  # @example Specify an endpoint with `:to` (controller and action string)
  #   require 'lotus/router'
  #
  #   router = Lotus::Router.new do
  #     get '/', to: 'articles#show' # => ArticlesController::Show
  #   end
  #
  #   # This is a builtin feature for a Lotus::Controller convention.
  #
  #
  #
  # @example Specify a prefix with `:prefix`
  #   require 'lotus/router'
  #
  #   endpoint = ->(env) { [200, {}, ['Welcome to Lotus::Router!']] }
  #   router = Lotus::Router.new do
  #     get '/welcome', to: endpoint, prefix: 'dashboard' # => '/dashboard/welcome'
  #   end
  #
  #   # :prefix isn't mandatory for the default resolver (`Lotus::Routing::EndpointResolver.new`),
  #   # This behavior can be changed by passing a custom resolver to `Lotus::Router#initialize`
  #
  #
  #
  # @example Specify a named route with `:as`
  #   require 'lotus/router'
  #
  #   endpoint = ->(env) { [200, {}, ['Welcome to Lotus::Router!']] }
  #   router = Lotus::Router.new(scheme: 'https', host: 'lotusrb.org') do
  #     get '/', to: endpoint, as: :root
  #   end
  #
  #   router.path(:root) # => '/'
  #   router.url(:root)  # => 'https://lotusrb.org/'
  #
  #   # This isn't mandatory for the default route class (`Lotus::Routing::Route`),
  #   # This behavior can be changed by passing a custom route to `Lotus::Router#initialize`
  class Router
    # Initialize the router.
    #
    # @param options [Hash] the options to initialize the router
    #
    # @option options [String] :scheme The HTTP scheme (defaults to `"http"`)
    # @option options [String] :host The URL host (defaults to `"localhost"`)
    # @option options [String] :port The URL port (defaults to `"80"`)
    # @option options [Object, #resolve, #find, #action_separator] :resolver
    #   the route resolver (defaults to `Lotus::Routing::EndpointResolver.new`)
    # @option options [Object, #generate] :route the route class
    #   (defaults to `Lotus::Routing::Route`)
    # @option options [String] :action_separator the separator between controller
    #   and action name (eg. 'dashboard#show', where '#' is the :action_separator)
    #
    # @param blk [Proc] the optional block to define the routes
    #
    # @return [Lotus::Router] self
    #
    # @since 0.1.0
    #
    # @example
    #   require 'lotus/router'
    #
    #   endpoint = ->(env) { [200, {}, ['Welcome to Lotus::Router!']] }
    #
    #   router = Lotus::Router.new
    #   router.get '/', to: endpoint
    #
    #   # or
    #
    #   router = Lotus::Router.new do
    #     get '/', to: endpoint
    #   end
    def initialize(options = {}, &blk)
      @router = Routing::HttpRouter.new(options)
      instance_eval(&blk) if block_given?
    end

    # Defines a route that accepts a GET request for the given path.
    #
    # @param path [String] the relative URL to be matched
    #
    # @param options [Hash] the options to customize the route
    # @option options [String,Proc,Class,Object#call] :to the endpoint
    # @option options [String] :prefix an optional path prefix
    #
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @return [Lotus::Roting::Route] this may vary according to the :route
    #   option passed to the constructor
    #
    # @since 0.1.0
    #
    # @example Fixed matching string
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new
    #   router.get '/lotus', to: ->(env) { [200, {}, ['Hello from Lotus!']] }
    #
    # @example String matching with variables
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new
    #   router.get '/flowers/:id',
    #     to: ->(env) {
    #       [
    #         200,
    #         {},
    #         ["Hello from Flower no. #{ env['router.params'][:id] }!"]
    #       ]
    #     }
    #
    # @example Variables Constraints
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new
    #   router.get '/flowers/:id',
    #     id: /\d+/,
    #     to: ->(env) { [200, {}, [":id must be a number!"]] }
    #
    # @example String matching with globbling
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new
    #   router.get '/*',
    #     to: ->(env) {
    #       [
    #         200,
    #         {},
    #         ["This is catch all: #{ env['router.params'].inspect }!"]
    #       ]
    #     }
    #
    # @example String matching with optional tokens
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new
    #   router.get '/lotus(.:format)',
    #     to: ->(env) {
    #       [200, {}, ["You've requested #{ env['router.params'][:format] }!"]]
    #     }
    #
    # @example Named routes
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new(scheme: 'https', host: 'lotusrb.org')
    #   router.get '/lotus',
    #     to: ->(env) { [200, {}, ['Hello from Lotus!']] },
    #     as: :lotus
    #
    #   router.path(:lotus) # => "/lotus"
    #   router.url(:lotus)  # => "https://lotusrb.org/lotus"
    #
    # @example Prefixed routes
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new
    #   router.get '/cats',
    #     prefix: '/animals/mammals',
    #     to: ->(env) { [200, {}, ['Meow!']] },
    #     as: :cats
    #
    #   router.path(:animals_mammals_cats) # => "/animals/mammals/cats"
    #
    # @example Duck typed endpoints (Rack compatible objects)
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new
    #
    #   router.get '/lotus',      to: ->(env) { [200, {}, ['Hello from Lotus!']] }
    #   router.get '/middleware', to: Middleware
    #   router.get '/rack-app',   to: RackApp.new
    #   router.get '/method',     to: ActionControllerSubclass.action(:new)
    #
    #   # Everything that responds to #call is invoked as it is
    #
    # @example Duck typed endpoints (strings)
    #   require 'lotus/router'
    #
    #   class RackApp
    #     def call(env)
    #       # ...
    #     end
    #   end
    #
    #   router = Lotus::Router.new
    #   router.get '/lotus', to: 'rack_app' # it will map to RackApp.new
    #
    # @example Duck typed endpoints (string: controller + action)
    #   require 'lotus/router'
    #
    #   class FlowersController
    #     class Index
    #       def call(env)
    #         # ...
    #       end
    #     end
    #    end
    #
    #    router = Lotus::Router.new
    #    router.get '/flowers', to: 'flowers#index'
    #
    #    # It will map to FlowersController::Index.new, which is the
    #    # Lotus::Controller convention.
    def get(path, options = {}, &blk)
      @router.get(path, options, &blk)
    end

    # Defines a route that accepts a POST request for the given path.
    #
    # @param path [String] the relative URL to be matched
    #
    # @param options [Hash] the options to customize the route
    # @option options [String,Proc,Class,Object#call] :to the endpoint
    # @option options [String] :prefix an optional path prefix
    #
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @return [Lotus::Roting::Route] this may vary according to the :route
    #   option passed to the constructor
    #
    # @see Lotus::Router#get
    #
    # @since 0.1.0
    def post(path, options = {}, &blk)
      @router.post(path, options, &blk)
    end

    # Defines a route that accepts a PUT request for the given path.
    #
    # @param path [String] the relative URL to be matched
    #
    # @param options [Hash] the options to customize the route
    # @option options [String,Proc,Class,Object#call] :to the endpoint
    # @option options [String] :prefix an optional path prefix
    #
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @return [Lotus::Roting::Route] this may vary according to the :route
    #   option passed to the constructor
    #
    # @see Lotus::Router#get
    #
    # @since 0.1.0
    def put(path, options = {}, &blk)
      @router.put(path, options, &blk)
    end

    # Defines a route that accepts a PATCH request for the given path.
    #
    # @param path [String] the relative URL to be matched
    #
    # @param options [Hash] the options to customize the route
    # @option options [String,Proc,Class,Object#call] :to the endpoint
    # @option options [String] :prefix an optional path prefix
    #
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @return [Lotus::Roting::Route] this may vary according to the :route
    #   option passed to the constructor
    #
    # @see Lotus::Router#get
    #
    # @since 0.1.0
    def patch(path, options = {}, &blk)
      @router.patch(path, options, &blk)
    end

    # Defines a route that accepts a DELETE request for the given path.
    #
    # @param path [String] the relative URL to be matched
    #
    # @param options [Hash] the options to customize the route
    # @option options [String,Proc,Class,Object#call] :to the endpoint
    # @option options [String] :prefix an optional path prefix
    #
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @return [Lotus::Roting::Route] this may vary according to the :route
    #   option passed to the constructor
    #
    # @see Lotus::Router#get
    #
    # @since 0.1.0
    def delete(path, options = {}, &blk)
      @router.delete(path, options, &blk)
    end

    # Defines a route that accepts a TRACE request for the given path.
    #
    # @param path [String] the relative URL to be matched
    #
    # @param options [Hash] the options to customize the route
    # @option options [String,Proc,Class,Object#call] :to the endpoint
    # @option options [String] :prefix an optional path prefix
    #
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @return [Lotus::Roting::Route] this may vary according to the :route
    #   option passed to the constructor
    #
    # @see Lotus::Router#get
    #
    # @since 0.1.0
    def trace(path, options = {}, &blk)
      @router.trace(path, options, &blk)
    end

    # Defines an HTTP redirect
    #
    # @param path [String] the path that needs to be redirected
    # @param options [Hash] the options to customize the redirect behavior
    # @option options [Fixnum] the HTTP status to return (defaults to `302`)
    #
    # @return [Lotus::Routing::Route] the generated route.
    #   This may vary according to the `:route` option passed to the initializer
    #
    # @since 0.1.0
    #
    # @see Lotus::Router
    #
    # @example
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     redirect '/legacy',  to: '/new_endpoint'
    #     redirect '/legacy2', to: '/new_endpoint2', code: 301
    #   end
    #
    # @example
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new
    #   router.redirect '/legacy',  to: '/new_endpoint'
    def redirect(path, options = {}, &endpoint)
      get(path).redirect @router.find(options), options[:code] || 302
    end

    # Defines a Ruby block: all the routes defined within it will be namespaced
    #   with the given prefix.
    #
    # Namespaces blocks can be nested multiple times.
    #
    # @param prefix [String] the path prefix
    # @param blk [Proc] the block that defines the resources
    #
    # @return [Lotus::Routing::Namespace] the generated namespace.
    #
    # @since 0.1.0
    #
    # @see Lotus::Router
    #
    # @example Basic example
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     namespace 'trees' do
    #       get '/sequoia', to: endpoint # => '/trees/sequoia'
    #     end
    #
    #     # equivalent to
    #
    #     get '/sequoia', to: endpoint, prefix: 'trees' # => '/trees/sequoia'
    #   end
    #
    # @example Nested namespaces
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     namespace 'animals' do
    #       namespace 'mammals' do
    #         get '/cats', to: endpoint # => '/animals/mammals/cats'
    #       end
    #     end
    #   end
    #
    # @example
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new
    #   router.namespace 'trees' do
    #     get '/sequoia', to: endpoint # => '/trees/sequoia'
    #   end
    def namespace(prefix, &blk)
      Routing::Namespace.new(self, prefix, &blk)
    end

    # Defines a set of named routes for a single RESTful resource.
    # It has a built-in integration for Lotus::Controller.
    #
    # @param name [String] the name of the resource
    # @param options [Hash] a set of options to customize the routes
    # @option options [Array<Symbol>] :only a subset of the default routes
    #   that we want to generate
    # @option options [Array<Symbol>] :except prevent the given routes to be
    #   generated
    # @param blk [Proc] a block of code to generate additional routes
    #
    # @return [Lotus::Routing::Resource]
    #
    # @since 0.1.0
    #
    # @see Lotus::Routing::Resource
    # @see Lotus::Routing::Resource::Action
    # @see Lotus::Routing::Resource::Options
    #
    # @example Default usage
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     resource 'identity'
    #   end
    #
    #   # It generates:
    #   #
    #   # +--------+----------------+-----------------------------+----------+----------------+
    #   # | Verb   | Path           | Action                      | Name     | Named Route    |
    #   # +--------+----------------+-----------------------------+----------+----------------+
    #   # | GET    | /identity      | IdentityController::Show    | :show    | :identity      |
    #   # | GET    | /identity/new  | IdentityController::New     | :new     | :new_identity  |
    #   # | POST   | /identity      | IdentityController::Create  | :create  | :identity      |
    #   # | GET    | /identity/edit | IdentityController::Edit    | :edit    | :edit_identity |
    #   # | PATCH  | /identity      | IdentityController::Update  | :update  | :identity      |
    #   # | DELETE | /identity      | IdentityController::Destroy | :destroy | :identity      |
    #   # +--------+----------------+-----------------------------+----------+----------------+
    #
    #
    #
    # @example Limit the generated routes with :only
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     resource 'identity', only: [:show, :new, :create]
    #   end
    #
    #   # It generates:
    #   #
    #   # +--------+----------------+-----------------------------+----------+----------------+
    #   # | Verb   | Path           | Action                      | Name     | Named Route    |
    #   # +--------+----------------+-----------------------------+----------+----------------+
    #   # | GET    | /identity      | IdentityController::Show    | :show    | :identity      |
    #   # | GET    | /identity/new  | IdentityController::New     | :new     | :new_identity  |
    #   # | POST   | /identity      | IdentityController::Create  | :create  | :identity      |
    #   # +--------+----------------+-----------------------------+----------+----------------+
    #
    #
    #
    # @example Limit the generated routes with :except
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     resource 'identity', except: [:edit, :update, :destroy]
    #   end
    #
    #   # It generates:
    #   #
    #   # +--------+----------------+-----------------------------+----------+----------------+
    #   # | Verb   | Path           | Action                      | Name     | Named Route    |
    #   # +--------+----------------+-----------------------------+----------+----------------+
    #   # | GET    | /identity      | IdentityController::Show    | :show    | :identity      |
    #   # | GET    | /identity/new  | IdentityController::New     | :new     | :new_identity  |
    #   # | POST   | /identity      | IdentityController::Create  | :create  | :identity      |
    #   # +--------+----------------+-----------------------------+----------+----------------+
    #
    #
    #
    # @example Additional single routes
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     resource 'identity', only: [] do
    #       member do
    #         patch 'activate'
    #       end
    #     end
    #   end
    #
    #   # It generates:
    #   #
    #   # +--------+--------------------+------------------------------+------+--------------------+
    #   # | Verb   | Path               | Action                       | Name | Named Route        |
    #   # +--------+--------------------+------------------------------+------+--------------------+
    #   # | PATCH  | /identity/activate | IdentityController::Activate |      | :activate_identity |
    #   # +--------+--------------------+------------------------------+------+--------------------+
    #
    #
    #
    # @example Additional collection routes
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     resource 'identity', only: [] do
    #       collection do
    #         get 'keys'
    #       end
    #     end
    #   end
    #
    #   # It generates:
    #   #
    #   # +------+----------------+--------------------------+------+----------------+
    #   # | Verb | Path           | Action                   | Name | Named Route    |
    #   # +------+----------------+--------------------------+------+----------------+
    #   # | GET  | /identity/keys | IdentityController::Keys |      | :keys_identity |
    #   # +------+----------------+--------------------------+------+----------------+
    def resource(name, options = {}, &blk)
      Routing::Resource.new(self, name, options.merge(separator: @router.action_separator), &blk)
    end

    # Defines a set of named routes for a plural RESTful resource.
    # It has a built-in integration for Lotus::Controller.
    #
    # @param name [String] the name of the resource
    # @param options [Hash] a set of options to customize the routes
    # @option options [Array<Symbol>] :only a subset of the default routes
    #   that we want to generate
    # @option options [Array<Symbol>] :except prevent the given routes to be
    #   generated
    # @param blk [Proc] a block of code to generate additional routes
    #
    # @return [Lotus::Routing::Resources]
    #
    # @since 0.1.0
    #
    # @see Lotus::Routing::Resources
    # @see Lotus::Routing::Resources::Action
    # @see Lotus::Routing::Resource::Options
    #
    # @example Default usage
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     resources 'articles'
    #   end
    #
    #   # It generates:
    #   #
    #   # +--------+--------------------+-----------------------------+----------+----------------+
    #   # | Verb   | Path               | Action                      | Name     | Named Route    |
    #   # +--------+--------------------+-----------------------------+----------+----------------+
    #   # | GET    | /articles          | ArticlesController::Index   | :index   | :articles      |
    #   # | GET    | /articles/:id      | ArticlesController::Show    | :show    | :articles      |
    #   # | GET    | /articles/new      | ArticlesController::New     | :new     | :new_articles  |
    #   # | POST   | /articles          | ArticlesController::Create  | :create  | :articles      |
    #   # | GET    | /articles/:id/edit | ArticlesController::Edit    | :edit    | :edit_articles |
    #   # | PATCH  | /articles/:id      | ArticlesController::Update  | :update  | :articles      |
    #   # | DELETE | /articles/:id      | ArticlesController::Destroy | :destroy | :articles      |
    #   # +--------+--------------------+-----------------------------+----------+----------------+
    #
    #
    #
    # @example Limit the generated routes with :only
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     resources 'articles', only: [:index]
    #   end
    #
    #   # It generates:
    #   #
    #   # +------+-----------+---------------------------+--------+-------------+
    #   # | Verb | Path      | Action                    | Name   | Named Route |
    #   # +------+-----------+---------------------------+--------+-------------+
    #   # | GET  | /articles | ArticlesController::Index | :index | :articles   |
    #   # +------+-----------+---------------------------+--------+-------------+
    #
    #
    #
    # @example Limit the generated routes with :except
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     resources 'articles', except: [:edit, :update]
    #   end
    #
    #   # It generates:
    #   #
    #   # +--------+--------------------+-----------------------------+----------+----------------+
    #   # | Verb   | Path               | Action                      | Name     | Named Route    |
    #   # +--------+--------------------+-----------------------------+----------+----------------+
    #   # | GET    | /articles          | ArticlesController::Index   | :index   | :articles      |
    #   # | GET    | /articles/:id      | ArticlesController::Show    | :show    | :articles      |
    #   # | GET    | /articles/new      | ArticlesController::New     | :new     | :new_articles  |
    #   # | POST   | /articles          | ArticlesController::Create  | :create  | :articles      |
    #   # | DELETE | /articles/:id      | ArticlesController::Destroy | :destroy | :articles      |
    #   # +--------+--------------------+-----------------------------+----------+----------------+
    #
    #
    #
    # @example Additional single routes
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     resources 'articles', only: [] do
    #       member do
    #         patch 'publish'
    #       end
    #     end
    #   end
    #
    #   # It generates:
    #   #
    #   # +--------+-----------------------+-----------------------------+------+-------------------+
    #   # | Verb   | Path                  | Action                      | Name | Named Route       |
    #   # +--------+-----------------------+-----------------------------+------+-------------------+
    #   # | PATCH  | /articles/:id/publish | ArticlesController::Publish |      | :publish_articles |
    #   # +--------+-----------------------+-----------------------------+------+-------------------+
    #
    #
    #
    # @example Additional collection routes
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     resources 'articles', only: [] do
    #       collection do
    #         get 'search'
    #       end
    #     end
    #   end
    #
    #   # It generates:
    #   #
    #   # +------+------------------+----------------------------+------+------------------+
    #   # | Verb | Path             | Action                     | Name | Named Route      |
    #   # +------+------------------+----------------------------+------+------------------+
    #   # | GET  | /articles/search | ArticlesController::Search |      | :search_articles |
    #   # +------+------------------+----------------------------+------+------------------+
    def resources(name, options = {}, &blk)
      Routing::Resources.new(self, name, options.merge(separator: @router.action_separator), &blk)
    end

    # Resolve the given Rack env to a registered endpoint and invoke it.
    #
    # @param env [Hash] a Rack env instance
    #
    # @return [Rack::Response, Array]
    #
    # @since 0.1.0
    def call(env)
      @router.call(env)
    end

    # Generate an relative URL for a specified named route.
    # The additional arguments will be used to compose the relative URL - in
    #   case it has tokens to match - and for compose the query string.
    #
    # @param route [Symbol] the route name
    #
    # @return [String]
    #
    # @raise [Lotus::Routing::InvalidRouteException] when the router fails to
    #   recognize a route, because of the given arguments.
    #
    # @since 0.1.0
    #
    # @example
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new(scheme: 'https', host: 'lotusrb.org')
    #   router.get '/login', to: 'sessions#new',    as: :login
    #   router.get '/:name', to: 'frameworks#show', as: :framework
    #
    #   router.path(:login)                          # => "/login"
    #   router.path(:login, return_to: '/dashboard') # => "/login?return_to=%2Fdashboard"
    #   router.path(:framework, name: 'router')      # => "/router"
    def path(route, *args)
      @router.path(route, *args)
    end

    # Generate a URL for a specified named route.
    # The additional arguments will be used to compose the relative URL - in
    #   case it has tokens to match - and for compose the query string.
    #
    # @param route [Symbol] the route name
    #
    # @return [String]
    #
    # @raise [Lotus::Routing::InvalidRouteException] when the router fails to
    #   recognize a route, because of the given arguments.
    #
    # @since 0.1.0
    #
    # @example
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new(scheme: 'https', host: 'lotusrb.org')
    #   router.get '/login', to: 'sessions#new', as: :login
    #   router.get '/:name', to: 'frameworks#show', as: :framework
    #
    #   router.url(:login)                          # => "https://lotusrb.org/login"
    #   router.url(:login, return_to: '/dashboard') # => "https://lotusrb.org/login?return_to=%2Fdashboard"
    #   router.url(:framework, name: 'router')      # => "https://lotusrb.org/router"
    def url(route, *args)
      @router.url(route, *args)
    end
  end
end
