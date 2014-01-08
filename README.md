# Lotus::Router

Rack compatible, lightweight and fast HTTP Router for Lotus.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lotus-router'
```

And then execute:

```shell
$ bundle
```

Or install it yourself as:

```shell
$ gem install lotus-router
```

## Usage

Lotus::Router supports a lot of neat features:

### A Beautiful DSL:

```ruby
Lotus::Router.new do
  get '/', to: ->(env) { [200, {}, ['Welcome to Lotus::Router!']] }
  get '/dashboard',   to: DashboardController::Index
  get '/rack-app',    to: RackApp.new
  get '/flowers',     to: 'flowers#index'
  get '/flowers/:id', to: 'flowers#show'
  get '/sinatra' do |env|
    [200, {}, ['Hello from a Sinatra-like endpoint!']]
  end

  redirect '/legacy', to: '/'

  namespace 'admin' do
    get '/users', to: UsersController::Index
  end

  resource 'identity' do
    member do
      get '/avatar'
    end

    collection do
      get '/api_keys'
    end
  end

  resources 'robots' do
    member do
      patch '/activate'
    end

    collection do
      get '/search'
    end
  end
end
```



### Fixed string matching:

```ruby
router = Lotus::Router.new
router.get '/lotus', to: ->(env) { [200, {}, ['Hello from Lotus!']] }
```



### String matching with variables:

```ruby
router = Lotus::Router.new
router.get '/flowers/:id', to: ->(env) { [200, {}, ["Hello from Flower no. #{ env['router.params'][:id] }!"]] }
```



### Variables Constraints:

```ruby
router = Lotus::Router.new
router.get '/flowers/:id', id: /\d+/, to: ->(env) { [200, {}, [":id must be a number!"]] }
```



### String matching with globbling:

```ruby
router = Lotus::Router.new
router.get '/*', to: ->(env) { [200, {}, ["This is catch all: #{ env['router.params'].inspect }!"]] }
```



### String matching with optional tokens:

```ruby
router = Lotus::Router.new
router.get '/lotus(.:format)' to: ->(env) { [200, {}, ["You've requested #{ env['router.params'][:format] }!"]] }
```



### Support for the most common HTTP methods:

```ruby
router   = Lotus::Router.new
endpoint = ->(env) { [200, {}, ['Hello from Lotus!']] }

router.get    '/lotus', to: endpoint
router.post   '/lotus', to: endpoint
router.put    '/lotus', to: endpoint
router.patch  '/lotus', to: endpoint
router.delete '/lotus', to: endpoint
router.trace  '/lotus', to: endpoint
```



### Redirect:

```ruby
router = Lotus::Router.new
router.get '/redirect_destination', to: ->(env) { [200, {}, ['Redirect destination!']] }
router.redirect '/legacy', to: '/redirect_destination'
```



### Named routes:

```ruby
router = Lotus::Router.new(scheme: 'https', host: 'lotusrb.org')
router.get '/lotus', to: ->(env) { [200, {}, ['Hello from Lotus!']] }, as: :lotus

router.path(:lotus) # => "/lotus"
router.url(:lotus)  # => "https://lotusrb.org/lotus"
```



### Namespaced routes:

```ruby
router = Lotus::Router.new
router.namespace 'animals' do
  namespace 'mammals' do
    get '/cats', to: ->(env) { [200, {}, ['Meow!']] }, as: :cats
  end
end

# or

router.get '/cats', prefix: '/animals/mammals', to:->(env) { [200, {}, ['Meow!']] }, as: :cats

# and it generates:

router.path(:animals_mammals_cats) # => "/animals/mammals/cats"
```



### Duck typed endpoints:

Everything that responds to `#call` is invoked as it is:

```ruby
router = Lotus::Router.new
router.get '/lotus',      to: ->(env) { [200, {}, ['Hello from Lotus!']] }
router.get '/middleware', to: Middleware
router.get '/rack-app',   to: RackApp.new
router.get '/method',     to: ActionControllerSubclass.action(:new)
```


If it's a string, it tries to instantiate a class from it:

```ruby
class RackApp
  def call(env)
    # ...
  end
end

router = Lotus::Router.new
router.get '/lotus', to: 'rack_app' # it will map to RackApp.new
```

It also supports Controller + Action syntax:

```ruby
class FlowersController
  class Index
    def call(env)
      # ...
    end
  end
end

router = Lotus::Router.new
router.get '/flowers', to: 'flowers#index' # it will map to FlowersController::Index.new
```



### Implicit Not Found (404):

```ruby
router = Lotus::Router.new
router.call(Rack::MockRequest.env_for('/unknown')).status # => 404
```



### RESTful Resource:

```ruby
router = Lotus::Router.new
router.resource 'identity'
```

It will map:

<table>
  <tr>
    <th>Verb</th>
    <th>Path</th>
    <th>Action</th>
    <th>Named Route</th>
  </tr>
  <tr>
    <td>GET</td>
    <td>/identity</td>
    <td>IdentityController::Show</td>
    <td>:identity</td>
  </tr>
  <tr>
    <td>GET</td>
    <td>/identity/new</td>
    <td>IdentityController::New</td>
    <td>:new_identity</td>
  </tr>
  <tr>
    <td>POST</td>
    <td>/identity</td>
    <td>IdentityController::Create</td>
    <td>:identity</td>
  </tr>
  <tr>
    <td>GET</td>
    <td>/identity/edit</td>
    <td>IdentityController::Edit</td>
    <td>:edit_identity</td>
  </tr>
  <tr>
    <td>PATCH</td>
    <td>/identity</td>
    <td>IdentityController::Update</td>
    <td>:identity</td>
  </tr>
  <tr>
    <td>DELETE</td>
    <td>/identity</td>
    <td>IdentityController::Destroy</td>
    <td>:identity</td>
  </tr>
</table>

If you don't need all the default endpoints, just do:

```ruby
router = Lotus::Router.new
router.resource 'identity', only: [:edit, :update]

# which is equivalent to:

router.resource 'identity', except: [:show, :new, :create, :destroy]
```


If you need extra endpoints:

```ruby
router = Lotus::Router.new
router.resource 'identity' do
  member do
   get '/avatar'            # maps to IdentityController::Avatar
  end

  collection do
    get '/authorizations'   # maps to IdentityController::Authorizations
  end
end

router.path(:avatar_identity)         # => /identity/avatar
router.path(:authorizations_identity) # => /identity/authorizations
```



### RESTful Resources:

```ruby
router = Lotus::Router.new
router.resources 'flowers'
```

It will map:

<table>
  <tr>
    <th>Verb</th>
    <th>Path</th>
    <th>Action</th>
    <th>Named Route</th>
  </tr>
  <tr>
    <td>GET</td>
    <td>/flowers</td>
    <td>FlowersController::Index</td>
    <td>:flowers</td>
  </tr>
  <tr>
    <td>GET</td>
    <td>/flowers/:id</td>
    <td>FlowersController::Show</td>
    <td>:flowers</td>
  </tr>
  <tr>
    <td>GET</td>
    <td>/flowers/new</td>
    <td>FlowersController::New</td>
    <td>:new_flowers</td>
  </tr>
  <tr>
    <td>POST</td>
    <td>/flowers</td>
    <td>FlowersController::Create</td>
    <td>:flowers</td>
  </tr>
  <tr>
    <td>GET</td>
    <td>/flowers/:id/edit</td>
    <td>FlowersController::Edit</td>
    <td>:edit_flowers</td>
  </tr>
  <tr>
    <td>PATCH</td>
    <td>/flowers/:id</td>
    <td>FlowersController::Update</td>
    <td>:flowers</td>
  </tr>
  <tr>
    <td>DELETE</td>
    <td>/flowers/:id</td>
    <td>FlowersController::Destroy</td>
    <td>:flowers</td>
  </tr>
</table>


```ruby
router.path(:flowers)              # => /flowers
router.path(:flowers, id: 23)      # => /flowers/23
router.path(:edit_flowers, id: 23) # => /flowers/23/edit
```



If you don't need all the default endpoints, just do:

```ruby
router = Lotus::Router.new
router.resources 'flowers', only: [:new, :create, :show]

# which is equivalent to:

router.resources 'flowers', except: [:index, :edit, :update, :destroy]
```


If you need extra endpoints:

```ruby
router = Lotus::Router.new
router.resources 'flowers' do
  member do
    get '/toggle' # maps to FlowersController::Toggle
  end
  collection do
    get '/search' # maps to FlowersController::Search
  end
end

router.path(:toggle_flowers, id: 23)  # => /flowers/23/toggle
router.path(:search_flowers)          # => /flowers/search
```



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
