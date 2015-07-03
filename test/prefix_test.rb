require 'test_helper'

module Prefix
  module Controllers
    module Home
      class Index
        def call(env)
          [200, {}, ['home']]
        end
      end
    end

    module Users
      class Index
        def call(env)
          [200, {}, ['users']]
        end
      end
    end

    module Asteroid
      class Show
        def call(env)
          [200, {}, ['asteroid']]
        end
      end
    end
  end
end

describe Lotus::Router do
  describe 'with prefix option' do
    before do
      @router = Lotus::Router.new(scheme: 'https', host: 'lotus.test', port: 443, prefix: '/admin', namespace: Prefix::Controllers) do
        get     '/home', to: 'home#index', as: :get_home
        post    '/home', to: 'home#index', as: :post_home
        put     '/home', to: 'home#index', as: :put_home
        patch   '/home', to: 'home#index', as: :patch_home
        delete  '/home', to: 'home#index', as: :delete_home
        trace   '/home', to: 'home#index', as: :trace_home
        options '/home', to: 'home#index', as: :options_home

        get  '/admin',      to: 'home#index', as: :get_admin
        get  '/admin/new',  to: 'home#index', as: :new_admin
        get  '/admin/edit', to: 'home#index', as: :edit_admin
        post '/admin',      to: 'home#index', as: :create_admin
        put  '/admin',      to: 'home#index', as: :put_admin

        resources :users
        resource :asteroid

        namespace :dashboard do
          get '/home', to: 'dashboard#index', as: :dashboard_home
        end
      end
    end

    it 'generates relative URLs with prefix' do
      @router.path(:get_home).must_equal     '/admin/home'
      @router.path(:post_home).must_equal    '/admin/home'
      @router.path(:put_home).must_equal     '/admin/home'
      @router.path(:patch_home).must_equal   '/admin/home'
      @router.path(:delete_home).must_equal  '/admin/home'
      @router.path(:trace_home).must_equal   '/admin/home'
      @router.path(:options_home).must_equal '/admin/home'

      @router.path(:users).must_equal            '/admin/users'
      @router.path(:new_user).must_equal         '/admin/users/new'
      @router.path(:users).must_equal            '/admin/users'
      @router.path(:user, id: 1).must_equal      '/admin/users/1'
      @router.path(:edit_user, id: 1).must_equal '/admin/users/1/edit'

      @router.path(:get_admin).must_equal    '/admin/admin'
      @router.path(:new_admin).must_equal    '/admin/admin/new'
      @router.path(:create_admin).must_equal '/admin/admin'
      @router.path(:edit_admin).must_equal   '/admin/admin/edit'
      @router.path(:put_admin).must_equal    '/admin/admin'

      @router.path(:new_asteroid).must_equal  '/admin/asteroid/new'
      @router.path(:asteroid).must_equal      '/admin/asteroid'
      @router.path(:edit_asteroid).must_equal '/admin/asteroid/edit'

      @router.path(:dashboard_home).must_equal '/admin/dashboard/home'
    end

    it 'generates absolute URLs with prefix' do
      @router.url(:get_home).must_equal     'https://lotus.test/admin/home'
      @router.url(:post_home).must_equal    'https://lotus.test/admin/home'
      @router.url(:put_home).must_equal     'https://lotus.test/admin/home'
      @router.url(:patch_home).must_equal   'https://lotus.test/admin/home'
      @router.url(:delete_home).must_equal  'https://lotus.test/admin/home'
      @router.url(:trace_home).must_equal   'https://lotus.test/admin/home'
      @router.url(:options_home).must_equal 'https://lotus.test/admin/home'

      @router.url(:users).must_equal            'https://lotus.test/admin/users'
      @router.url(:new_user).must_equal         'https://lotus.test/admin/users/new'
      @router.url(:users).must_equal            'https://lotus.test/admin/users'
      @router.url(:user, id: 1).must_equal      'https://lotus.test/admin/users/1'
      @router.url(:edit_user, id: 1).must_equal 'https://lotus.test/admin/users/1/edit'

      @router.url(:new_asteroid).must_equal  'https://lotus.test/admin/asteroid/new'
      @router.url(:asteroid).must_equal      'https://lotus.test/admin/asteroid'
      @router.url(:edit_asteroid).must_equal 'https://lotus.test/admin/asteroid/edit'

      @router.url(:dashboard_home).must_equal 'https://lotus.test/admin/dashboard/home'
    end

    %w(GET POST PUT PATCH DELETE TRACE OPTIONS).each do |verb|
      it "recognizes requests (#{ verb })" do
        env = Rack::MockRequest.env_for('/home', method: verb)
        status, _, body = @router.call(env)

        status.must_equal 200
        body.must_equal  ['home']
      end
    end

    it "recognizes RESTful resources" do
      env = Rack::MockRequest.env_for('/users')
      status, _, body = @router.call(env)

      status.must_equal 200
      body.must_equal  ['users']
    end

    it "recognizes RESTful resource" do
      env = Rack::MockRequest.env_for('/asteroid')
      status, _, body = @router.call(env)

      status.must_equal 200
      body.must_equal  ['asteroid']
    end

    it 'redirect works with prefix' do
      router = Lotus::Router.new(prefix: '/admin') do
        redirect '/redirect', to: '/redirect_destination'
        get '/redirect_destination', to: ->(env) { [200, {}, ['Redirect destination!']] }
      end

      env = Rack::MockRequest.env_for('/redirect')
      status, headers, _ = router.call(env)

      status.must_equal 301
      headers['Location'].must_equal '/redirect_destination'
    end
  end
end
