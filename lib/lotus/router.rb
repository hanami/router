require 'http_router'
require 'lotus/utils/io'
require 'lotus/routing/endpoint_resolver'
require 'lotus/routing/route'
require 'lotus/routing/namespace'
require 'lotus/routing/resource'
require 'lotus/routing/resources'

Lotus::Utils::IO.silence_warnings do
  HttpRouter::Route::VALID_HTTP_VERBS = %w{GET POST PUT PATCH DELETE HEAD OPTIONS TRACE}
end

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
  # @example Specify the endpoint with `:to`
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
  class Router < HttpRouter
    attr_reader :resolver

    # Initialize the router.
    #
    # @param options [Hash] the options to initialize the router
    # @option options [String] :scheme The HTTP scheme (defaults to `"http"`)
    # @option options [String] :host The URL host (defaults to `"localhost"`)
    # @option options [String] :port The URL port (defaults to `"80"`)
    # @option options [Object, #resolve, #find] :resolver the route resolver (defaults to `Lotus::Routing::EndpointResolver.new`)
    # @option options [Object, #generate] :route the route class (defaults to `Lotus::Routing::Route`)
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
      super(options, &nil)

      @default_scheme = options[:scheme]   if options[:scheme]
      @default_host   = options[:host]     if options[:host]
      @default_port   = options[:port]     if options[:port]
      @resolver       = options[:resolver] || Routing::EndpointResolver.new
      @route_class    = options[:route]    || Routing::Route

      instance_eval(&blk) if block_given?
    end

    # Defines an HTTP redirect
    #
    # @param path [String] the path that needs to be redirected
    # @param options [Hash] the path that needs to be redirected
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
      get(path).redirect resolver.find(options), options[:code] || 302
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
      Routing::Resource.new(self, name, options, &blk)
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
      Routing::Resources.new(self, name, options, &blk)
    end

    # @api private
    def reset!
      uncompile
      @routes, @named_routes, @root = [], Hash.new{|h,k| h[k] = []}, Node::Root.new(self)
      @default_host, @default_port, @default_scheme = 'localhost', 80, 'http'
    end

    # @api private
    def pass_on_response(response)
      super response.to_a
    end

    # @api private
    def no_response(request, env)
      if request.acceptable_methods.any? && !request.acceptable_methods.include?(env['REQUEST_METHOD'])
        [405, {'Allow' => request.acceptable_methods.sort.join(", ")}, []]
      else
        @default_app.call(env)
      end
    end

    private
    def add_with_request_method(path, method, opts = {}, &app)
      super.generate(resolver, opts, &app)
    end
  end
end
