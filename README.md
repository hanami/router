# Lotus::Router

Rack compatible, lightweight and fast HTTP Router for [Lotus](http://lotusrb.org).

## Status

[![Gem Version](http://img.shields.io/gem/v/lotus-router.svg)](https://badge.fury.io/rb/lotus-router)
[![Build Status](http://img.shields.io/travis/lotus/router/master.svg)](https://travis-ci.org/lotus/router?branch=master)
[![Coverage](http://img.shields.io/coveralls/lotus/router/master.svg)](https://coveralls.io/r/lotus/router)
[![Code Climate](http://img.shields.io/codeclimate/github/lotus/router.svg)](https://codeclimate.com/github/lotus/router)
[![Dependencies](http://img.shields.io/gemnasium/lotus/router.svg)](https://gemnasium.com/lotus/router)
[![Inline docs](http://inch-ci.org/github/lotus/router.png)](http://inch-ci.org/github/lotus/router)

## Contact

* Home page: http://lotusrb.org
* Mailing List: http://lotusrb.org/mailing-list
* API Doc: http://rdoc.info/gems/lotus-router
* Bugs/Issues: https://github.com/lotus/router/issues
* Support: http://stackoverflow.com/questions/tagged/lotus-ruby
* Chat: https://gitter.im/lotus/chat

## Rubies

__Lotus::Router__ supports Ruby (MRI) 2+, JRuby 1.7 (with 2.0 mode) and Rubinius 2.3.0+.


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
  get '/dashboard',   to: Dashboard::Index
  get '/rack-app',    to: RackApp.new
  get '/flowers',     to: 'flowers#index'
  get '/flowers/:id', to: 'flowers#show'

  redirect '/legacy', to: '/'

  mount Api::App, to: '/api'

  namespace 'admin' do
    get '/users', to: Users::Index
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

# and it generates:

router.path(:animals_mammals_cats) # => "/animals/mammals/cats"
```



### Mount Rack applications:

```ruby
Lotus::Router.new do
  mount RackOne,                             at: '/rack1'
  mount RackTwo,                             at: '/rack2'
  mount RackThree.new,                       at: '/rack3'
  mount ->(env) {[200, {}, ['Rack Four']]},  at: '/rack4'
  mount 'dashboard#index',                   at: '/dashboard'
end
```

1. `RackOne` is used as it is (class), because it respond to `.call`
2. `RackTwo` is initialized, because it respond to `#call`
3. `RackThree` is used as it is (object), because it respond to `#call`
4. That Proc is used as it is, because it respond to `#call`
5. That string is resolved as `Dashboard::Index` ([Lotus::Controller](https://github.com/lotus/controller) integration)



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
module Flowers
  class Index
    def call(env)
      # ...
    end
  end
end

router = Lotus::Router.new
router.get '/flowers', to: 'flowers#index' # it will map to Flowers::Index.new
```



### Implicit Not Found (404):

```ruby
router = Lotus::Router.new
router.call(Rack::MockRequest.env_for('/unknown')).status # => 404
```

### Controllers:

`Lotus::Router` has a special convention for controllers naming.
It allows to declare an action as an endpoint, with a special syntax: `<controller>#<action>`.

```ruby
Lotus::Router.new do
  get '/', to: 'welcome#index'
end
```

In the example above, the router will look for the `Welcome::Index` action.

#### Namespaces

In applications where for maintainability or technical reasons, this convention
can't work, `Lotus::Router` can accept a `:namespace` option, which defines the
Ruby namespace where to look for actions.

For instance, given a Lotus full stack application called `Bookshelf`, the
controllers are available under `Bookshelf::Controllers`.

```ruby
Lotus::Router.new(namespace: Bookshelf::Controllers) do
  get '/', to: 'welcome#index'
end
```

In the example above, the router will look for the `Bookshelf::Controllers::Welcome::Index` action.

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
    <th>Name</th>
    <th>Named Route</th>
  </tr>
  <tr>
    <td>GET</td>
    <td>/identity</td>
    <td>Identity::Show</td>
    <td>:show</td>
    <td>:identity</td>
  </tr>
  <tr>
    <td>GET</td>
    <td>/identity/new</td>
    <td>Identity::New</td>
    <td>:new</td>
    <td>:new_identity</td>
  </tr>
  <tr>
    <td>POST</td>
    <td>/identity</td>
    <td>Identity::Create</td>
    <td>:create</td>
    <td>:identity</td>
  </tr>
  <tr>
    <td>GET</td>
    <td>/identity/edit</td>
    <td>Identity::Edit</td>
    <td>:edit</td>
    <td>:edit_identity</td>
  </tr>
  <tr>
    <td>PATCH</td>
    <td>/identity</td>
    <td>Identity::Update</td>
    <td>:update</td>
    <td>:identity</td>
  </tr>
  <tr>
    <td>DELETE</td>
    <td>/identity</td>
    <td>Identity::Destroy</td>
    <td>:destroy</td>
    <td>:identity</td>
  </tr>
</table>

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
    get 'avatar'           # maps to Identity::Avatar
  end

  collection do
    get 'authorizations'   # maps to Identity::Authorizations
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
    <th>Name</th>
    <th>Named Route</th>
  </tr>
  <tr>
    <td>GET</td>
    <td>/flowers</td>
    <td>Flowers::Index</td>
    <td>:index</td>
    <td>:flowers</td>
  </tr>
  <tr>
    <td>GET</td>
    <td>/flowers/:id</td>
    <td>Flowers::Show</td>
    <td>:show</td>
    <td>:flowers</td>
  </tr>
  <tr>
    <td>GET</td>
    <td>/flowers/new</td>
    <td>Flowers::New</td>
    <td>:new</td>
    <td>:new_flowers</td>
  </tr>
  <tr>
    <td>POST</td>
    <td>/flowers</td>
    <td>Flowers::Create</td>
    <td>:create</td>
    <td>:flowers</td>
  </tr>
  <tr>
    <td>GET</td>
    <td>/flowers/:id/edit</td>
    <td>Flowers::Edit</td>
    <td>:edit</td>
    <td>:edit_flowers</td>
  </tr>
  <tr>
    <td>PATCH</td>
    <td>/flowers/:id</td>
    <td>Flowers::Update</td>
    <td>:update</td>
    <td>:flowers</td>
  </tr>
  <tr>
    <td>DELETE</td>
    <td>/flowers/:id</td>
    <td>Flowers::Destroy</td>
    <td>:destroy</td>
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

#### which is equivalent to:

router.resources 'flowers', except: [:index, :edit, :update, :destroy]
```


If you need extra endpoints:

```ruby
router = Lotus::Router.new
router.resources 'flowers' do
  member do
    get 'toggle' # maps to Flowers::Toggle
  end

  collection do
    get 'search' # maps to Flowers::Search
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
