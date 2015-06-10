require 'test_helper'

describe Lotus::Router do
  describe 'with prefix option' do
    it 'generates routes with prefix' do
      router = Lotus::Router.new(prefix: '/admin') do
        get     '/home', to: 'home#index', as: :get_home
        post    '/home', to: 'home#index', as: :post_home
        put     '/home', to: 'home#index', as: :put_home
        patch   '/home', to: 'home#index', as: :patch_home
        delete  '/home', to: 'home#index', as: :delete_home
        trace   '/home', to: 'home#index', as: :trace_home
        options '/home', to: 'home#index', as: :options_home


        resources :users
        resource :asteroid

        namespace :dashboard do
          get '/home', to: 'dashboard#index', as: :dashboard_home
        end
      end
      router.path(:get_home).must_equal    '/admin/home'
      router.path(:post_home).must_equal   '/admin/home'
      router.path(:put_home).must_equal    '/admin/home'
      router.path(:patch_home).must_equal  '/admin/home'
      router.path(:delete_home).must_equal '/admin/home'
      router.path(:trace_home).must_equal  '/admin/home'
      router.path(:options_home).must_equal'/admin/home'

      router.path(:users).must_equal            '/admin/users'
      router.path(:new_user).must_equal         '/admin/users/new'
      router.path(:users).must_equal            '/admin/users'
      router.path(:user, id: 1).must_equal      '/admin/users/1'
      router.path(:edit_user, id: 1).must_equal '/admin/users/1/edit'

      router.path(:new_asteroid).must_equal  '/admin/asteroid/new'
      router.path(:asteroid).must_equal      '/admin/asteroid'
      router.path(:edit_asteroid).must_equal '/admin/asteroid/edit'

      router.path(:dashboard_home).must_equal '/admin/dashboard/home'
    end

    it 'redirect works with prefix' do
      router = Lotus::Router.new(prefix: '/admin')
      endpoint = ->(env) { [200, {}, ['Redirect destination!']] }
      router.redirect('/redirect', to: '/redirect_destination')

      env = Rack::MockRequest.env_for('/admin/redirect')
      status, headers, _ = router.call(env)

      status.must_equal 301
      headers['Location'].must_equal '/redirect_destination'
    end
  end
end
