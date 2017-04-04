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

describe Hanami::Router do
  describe 'with prefix option' do
    before do
      @router = Hanami::Router.new(scheme: 'https', host: 'hanami.test', port: 443, prefix: '/admin', namespace: Prefix::Controllers) do
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
      expect(@router.path(:get_home)).to eq(     '/admin/home')
      expect(@router.path(:post_home)).to eq(    '/admin/home')
      expect(@router.path(:put_home)).to eq(     '/admin/home')
      expect(@router.path(:patch_home)).to eq(   '/admin/home')
      expect(@router.path(:delete_home)).to eq(  '/admin/home')
      expect(@router.path(:trace_home)).to eq(   '/admin/home')
      expect(@router.path(:options_home)).to eq( '/admin/home')

      expect(@router.path(:users)).to eq(            '/admin/users')
      expect(@router.path(:new_user)).to eq(         '/admin/users/new')
      expect(@router.path(:users)).to eq(            '/admin/users')
      expect(@router.path(:user, id: 1)).to eq(      '/admin/users/1')
      expect(@router.path(:edit_user, id: 1)).to eq( '/admin/users/1/edit')

      expect(@router.path(:get_admin)).to eq(    '/admin/admin')
      expect(@router.path(:new_admin)).to eq(    '/admin/admin/new')
      expect(@router.path(:create_admin)).to eq( '/admin/admin')
      expect(@router.path(:edit_admin)).to eq(   '/admin/admin/edit')
      expect(@router.path(:put_admin)).to eq(    '/admin/admin')

      expect(@router.path(:new_asteroid)).to eq(  '/admin/asteroid/new')
      expect(@router.path(:asteroid)).to eq(      '/admin/asteroid')
      expect(@router.path(:edit_asteroid)).to eq( '/admin/asteroid/edit')

      expect(@router.path(:dashboard_home)).to eq( '/admin/dashboard/home')
    end

    it 'generates absolute URLs with prefix' do
      expect(@router.url(:get_home)).to eq(     'https://hanami.test/admin/home')
      expect(@router.url(:post_home)).to eq(    'https://hanami.test/admin/home')
      expect(@router.url(:put_home)).to eq(     'https://hanami.test/admin/home')
      expect(@router.url(:patch_home)).to eq(   'https://hanami.test/admin/home')
      expect(@router.url(:delete_home)).to eq(  'https://hanami.test/admin/home')
      expect(@router.url(:trace_home)).to eq(   'https://hanami.test/admin/home')
      expect(@router.url(:options_home)).to eq( 'https://hanami.test/admin/home')

      expect(@router.url(:users)).to eq(            'https://hanami.test/admin/users')
      expect(@router.url(:new_user)).to eq(         'https://hanami.test/admin/users/new')
      expect(@router.url(:users)).to eq(            'https://hanami.test/admin/users')
      expect(@router.url(:user, id: 1)).to eq(      'https://hanami.test/admin/users/1')
      expect(@router.url(:edit_user, id: 1)).to eq( 'https://hanami.test/admin/users/1/edit')

      expect(@router.url(:new_asteroid)).to eq(  'https://hanami.test/admin/asteroid/new')
      expect(@router.url(:asteroid)).to eq(      'https://hanami.test/admin/asteroid')
      expect(@router.url(:edit_asteroid)).to eq( 'https://hanami.test/admin/asteroid/edit')

      expect(@router.url(:dashboard_home)).to eq( 'https://hanami.test/admin/dashboard/home')
    end

    %w(GET POST PUT PATCH DELETE TRACE OPTIONS).each do |verb|
      it "recognizes requests (#{ verb })" do
        env = Rack::MockRequest.env_for('/home', method: verb)
        status, _, body = @router.call(env)

        expect(status).to eq( 200)
        expect(body).to eq(  ['home'])
      end
    end

    it "recognizes RESTful resources" do
      env = Rack::MockRequest.env_for('/users')
      status, _, body = @router.call(env)

      expect(status).to eq( 200)
      expect(body).to eq(  ['users'])
    end

    it "recognizes RESTful resource" do
      env = Rack::MockRequest.env_for('/asteroid')
      status, _, body = @router.call(env)

      expect(status).to eq( 200)
      expect(body).to eq(  ['asteroid'])
    end

    it 'redirect works with prefix' do
      router = Hanami::Router.new(prefix: '/admin') do
        redirect '/redirect', to: '/redirect_destination'
        get '/redirect_destination', to: ->(env) { [200, {}, ['Redirect destination!']] }
      end

      env = Rack::MockRequest.env_for('/redirect')
      status, headers, _ = router.call(env)

      expect(status).to eq( 301)
      expect(headers['Location']).to eq( '/redirect_destination')
    end
  end
end
