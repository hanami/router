# Lotus::Router

Rack compatible, lightweight and fast HTTP Router for [Lotus](http://lotusrb.org).

## Status

[![Gem Version](http://img.shields.io/gem/v/lotus-router.svg)](https://badge.fury.io/rb/lotus-router)
[![Build Status](http://img.shields.io/travis/lotus/router/master.svg)](https://travis-ci.org/lotus/router?branch=master)
[![Coverage](http://img.shields.io/coveralls/lotus/router/master.svg)](https://coveralls.io/r/lotus/router)
[![Code Climate](http://img.shields.io/codeclimate/github/lotus/router.svg)](https://codeclimate.com/github/lotus/router)
[![Dependencies](http://img.shields.io/gemnasium/lotus/router.svg)](https://gemnasium.com/lotus/router)
[![Inline Docs](http://inch-pages.github.io/github/lotus/router.svg)](http://inch-pages.github.io/github/lotus/router)
[![Trending](https://d2weczhvl823v0.cloudfront.net/lotus/router/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

## Contact

* Home page: http://lotusrb.org
* Mailing List: http://lotusrb.org/mailing-list
* API Doc: http://rdoc.info/gems/lotus-router
* Bugs/Issues: https://github.com/lotus/router/issues
* Support: http://stackoverflow.com/questions/tagged/lotus-ruby

## Rubies

__Lotus::Router__ supports Ruby (MRI) 2+


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

## Getting Started

```ruby
require 'lotus/router'

app = Lotus::Router.new do
  get '/', to: ->(env) { [200, {}, ['Welcome to Lotus::Router!']] }
end

Rack::Server.start app: app, Port: 2306
```

## Usage

__Lotus::Router__ is designed to work as a standalone framework or within a
context of a [Lotus](http://lotusrb.org) application.

For the standalone usage, it supports neat features:

### A Beautiful DSL:

```ruby
Lotus::Router.new do
  get '/', to: ->(env) { [200, {}, ['Hi!']] }
  get '/dashboard',   to: DashboardController::Index
  get '/rack-app',    to: RackApp.new
  get '/flowers',     to: 'flowers#index'
  get '/flowers/:id', to: 'flowers#show'

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



### String matching with globbing:

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

| Verb   | Path           | Action                      | Name     | Named Route
|--------|----------------|-----------------------------|----------|------------
| GET    | /identity      | IdentityController::Show    | :show    | :identity
| GET    | /identity/new  | IdentityController::New     | :new     | :new_identity
| POST   | /identity      | IdentityController::Create  | :create  | :identity
| GET    | /identity/edit | IdentityController::Edit    | :edit    | :edit_identity
| PATCH  | /identity      | IdentityController::Update  | :update  | :identity
| DELETE | /identity      | IdentityController::Destroy | :destroy | :identity

If you don't need all the default endpoints, just do:

```ruby
router = Lotus::Router.new
router.resource 'identity', only: [:edit, :update]

#### which is equivalent to:

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

| Verb   | Path              | Action                     | Name     | Named Route
|--------|-------------------|----------------------------|----------|------------
| GET    | /flowers          | FlowersController::Index   | :index   | :flowers
| GET    | /flowers/:id      | FlowersController::Show    | :show    | :flowers
| GET    | /flowers/new      | FlowersController::New     | :new     | :new_flowers
| POST   | /flowers          | FlowersController::Create  | :create  | :flowers
| GET    | /flowers/:id/edit | FlowersController::Edit    | :edit    | :edit_flowers
| PATCH  | /flowers/:id      | FlowersController::Update  | :update  | :flowers
| DELETE | /flowers/:id      | FlowersController::Destroy | :destroy | :flowers

```ruby
router.path(:flowers)              # => /flowers
router.path(:flowers, id: 23)      # => /flowers/23
router.path(:edit_flowers, id: 23) # => /flowers/23/edit
```



If you don't need all the default endpoints, just do:

```ruby
router = Lotus::Router.new
router.resources 'flowers', only: [:new, :create, :show]

#### which is equivalent to:

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

## Testing

```ruby
require 'lotus/router'
require 'rack/request'

router = Lotus::Router.new do
  get '/', to: ->(env) { [200, {}, ['Hi!']] }
end

app = Rack::MockRequest.new(router)
app.get('/') # => #<Rack::MockResponse:0x007fc4540dc238 ...>
```

## Versioning

__Lotus::Router__ uses [Semantic Versioning 2.0.0](http://semver.org)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Acknowledgements

Thanks to Joshua Hull ([@joshbuddy](https://github.com/joshbuddy)) for his
[http_router](http://rubygems.org/gems/http_router).

## Copyright

Copyright 2014 Luca Guidi – Released under MIT License
