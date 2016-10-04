require 'test_helper'

describe Hanami::Router do
  before do
    @router = Hanami::Router.new
    @app    = Rack::MockRequest.new(@router)
  end

  after do
    @router.reset!
  end

  describe '#namespace' do
    it 'recognizes get path' do
      @router.namespace 'trees' do
        get '/plane-tree', to: ->(env) { [200, {}, ['Trees (GET)!']] }
      end

      @app.request('GET', '/trees/plane-tree', lint: true).body.must_equal 'Trees (GET)!'
    end

    it 'recognizes post path' do
      @router.namespace 'trees' do
        post '/sequoia', to: ->(env) { [200, {}, ['Trees (POST)!']] }
      end

      @app.request('POST', '/trees/sequoia', lint: true).body.must_equal 'Trees (POST)!'
    end

    it 'recognizes put path' do
      @router.namespace 'trees' do
        put '/cherry-tree', to: ->(env) { [200, {}, ['Trees (PUT)!']] }
      end

      @app.request('PUT', '/trees/cherry-tree', lint: true).body.must_equal 'Trees (PUT)!'
    end

    it 'recognizes patch path' do
      @router.namespace 'trees' do
        patch '/cedar', to: ->(env) { [200, {}, ['Trees (PATCH)!']] }
      end

      @app.request('PATCH', '/trees/cedar', lint: true).body.must_equal 'Trees (PATCH)!'
    end

    it 'recognizes delete path' do
      @router.namespace 'trees' do
        delete '/pine', to: ->(env) { [200, {}, ['Trees (DELETE)!']] }
      end

      @app.request('DELETE', '/trees/pine', lint: true).body.must_equal 'Trees (DELETE)!'
    end

    it 'recognizes trace path' do
      @router.namespace 'trees' do
        trace '/cypress', to: ->(env) { [200, {}, ['Trees (TRACE)!']] }
      end

      @app.request('TRACE', '/trees/cypress', lint: true).body.must_equal 'Trees (TRACE)!'
    end

    it 'recognizes options path' do
      @router.namespace 'trees' do
        options '/oak', to: ->(env) { [200, {}, ['Trees (OPTIONS)!']] }
      end

      @app.request('OPTIONS', '/trees/oak', lint: true).body.must_equal 'Trees (OPTIONS)!'
    end

    describe 'nested' do
      it 'defines HTTP methods correctly' do
        @router.namespace 'animals' do
          namespace 'mammals' do
            get '/cats', to: ->(env) { [200, {}, ['Meow!']] }
          end
        end

        @app.request('GET', '/animals/mammals/cats', lint: true).body.must_equal 'Meow!'
      end

      it 'defines #resource correctly' do
        @router.namespace 'users' do
          namespace 'management' do
            resource 'avatar'
          end
        end

        @app.request('GET', '/users/management/avatar', lint: true).body.must_equal 'Avatar::Show'
        @router.path(:users_management_avatar).must_equal "/users/management/avatar"
      end

      it 'defines #resources correctly' do
        @router.namespace 'vegetals' do
          namespace 'pretty' do
            resources 'flowers'
          end
        end

        @app.request('GET', '/vegetals/pretty/flowers', lint: true).body.must_equal 'Flowers::Index'
        @router.path(:vegetals_pretty_flowers).must_equal "/vegetals/pretty/flowers"
      end

      it 'defines #redirect correctly' do
        @router.namespace 'users' do
          namespace 'settings' do
            redirect '/image', to: '/avatar'
          end
        end

        @app.request('GET', 'users/settings/image', lint: true).headers['Location'].must_equal '/users/settings/avatar'
      end
    end

    describe 'redirect' do
      before do
        @router.namespace 'users' do
          get '/home', to: ->(env) { [200, {}, ['New Home!']] }
          redirect '/dashboard', to: '/home'
        end
      end

      it 'recognizes get path' do
        @app.request('GET', '/users/dashboard', lint: true).headers['Location'].must_equal '/users/home'
        @app.request('GET', '/users/dashboard', lint: true).status.must_equal 301
      end
    end

    describe 'restful resources' do
      before do
        @router.namespace 'vegetals' do
          resources 'flowers'
        end
      end

      it 'recognizes get index' do
        @router.path(:vegetals_flowers).must_equal              '/vegetals/flowers'
        @app.request('GET', '/vegetals/flowers', lint: true).body.must_equal         'Flowers::Index'
      end

      it 'recognizes get new' do
        @router.path(:new_vegetals_flower).must_equal          '/vegetals/flowers/new'
        @app.request('GET', '/vegetals/flowers/new', lint: true).body.must_equal     'Flowers::New'
      end

      it 'recognizes post create' do
        @router.path(:vegetals_flowers).must_equal                       '/vegetals/flowers'
        @app.request('POST', '/vegetals/flowers', lint: true).body.must_equal        'Flowers::Create'
      end

      it 'recognizes get show' do
        @router.path(:vegetals_flower, id: 23).must_equal               '/vegetals/flowers/23'
        @app.request('GET', '/vegetals/flowers/23', lint: true).body.must_equal      'Flowers::Show 23'
      end

      it 'recognizes get edit' do
        @router.path(:edit_vegetals_flower, id: 23).must_equal          '/vegetals/flowers/23/edit'
        @app.request('GET', '/vegetals/flowers/23/edit', lint: true).body.must_equal 'Flowers::Edit 23'
      end

      it 'recognizes patch update' do
        @router.path(:vegetals_flower, id: 23).must_equal               '/vegetals/flowers/23'
        @app.request('PATCH', '/vegetals/flowers/23', lint: true).body.must_equal    'Flowers::Update 23'
      end

      it 'recognizes delete destroy' do
        @router.path(:vegetals_flower, id: 23).must_equal               '/vegetals/flowers/23'
        @app.request('DELETE', '/vegetals/flowers/23', lint: true).body.must_equal   'Flowers::Destroy 23'
      end

      describe ':only option' do
        before do
          @router.namespace 'electronics' do
            resources 'keyboards', only: [:index, :edit]
          end
        end

        it 'recognizes only specified paths' do
          @router.path(:electronics_keyboards).must_equal                       '/electronics/keyboards'
          @app.request('GET', '/electronics/keyboards', lint: true).body.must_equal         'Keyboards::Index'

          @router.path(:edit_electronics_keyboard, id: 23).must_equal          '/electronics/keyboards/23/edit'
          @app.request('GET', '/electronics/keyboards/23/edit', lint: true).body.must_equal 'Keyboards::Edit 23'
        end

        it 'does not recognize other paths' do
          @app.request('GET',    '/electronics/keyboards/new', lint: true).status.must_equal 404
          @app.request('POST',   '/electronics/keyboards', lint: true).status.must_equal     405
          @app.request('GET',    '/electronics/keyboards/23', lint: true).status.must_equal  404
          @app.request('PATCH',  '/electronics/keyboards/23', lint: true).status.must_equal  405
          @app.request('DELETE', '/electronics/keyboards/23', lint: true).status.must_equal  405

          exception = -> { @router.path(:new_electronics_keyboards) }.must_raise Hanami::Routing::InvalidRouteException
          exception.message.must_equal 'No route (path) could be generated for :new_electronics_keyboards - please check given arguments'
        end
      end

      describe ':except option' do
        before do
          @router.namespace 'electronics' do
            resources 'keyboards', except: [:new, :show, :update, :destroy]
          end
        end

        it 'recognizes only the non-rejected paths' do
          @router.path(:electronics_keyboards).must_equal                       '/electronics/keyboards'
          @app.request('GET', '/electronics/keyboards', lint: true).body.must_equal         'Keyboards::Index'

          @router.path(:edit_electronics_keyboard, id: 23).must_equal          '/electronics/keyboards/23/edit'
          @app.request('GET', '/electronics/keyboards/23/edit', lint: true).body.must_equal 'Keyboards::Edit 23'

          @router.path(:electronics_keyboards).must_equal                       '/electronics/keyboards'
          @app.request('POST', '/electronics/keyboards', lint: true).body.must_equal        'Keyboards::Create'
        end

        it 'does not recognize other paths' do
          @app.request('GET',    '/electronics/keyboards/new', lint: true).status.must_equal 404
          @app.request('PATCH',  '/electronics/keyboards/23', lint: true).status.must_equal  405
          @app.request('DELETE', '/electronics/keyboards/23', lint: true).status.must_equal  405

          exception = -> { @router.path(:new_electronics_keyboards) }.must_raise Hanami::Routing::InvalidRouteException
          exception.message.must_equal 'No route (path) could be generated for :new_electronics_keyboards - please check given arguments'
        end
      end

      describe 'additional actions' do
        before do
          @router.namespace 'electronics' do
            resources 'keyboards' do
              collection { get 'search' }
              member     { get 'screenshot' }
            end
          end
        end

        it 'recognizes collection actions' do
          @router.path(:search_electronics_keyboards).must_equal               '/electronics/keyboards/search'
          @app.request('GET', "/electronics/keyboards/search", lint: true).body.must_equal 'Keyboards::Search'
        end

        it 'recognizes member actions' do
          @router.path(:screenshot_electronics_keyboard, id: 23).must_equal          '/electronics/keyboards/23/screenshot'
          @app.request('GET', "/electronics/keyboards/23/screenshot", lint: true).body.must_equal 'Keyboards::Screenshot 23'
        end
      end
    end

    describe 'restful resource' do
      before do
        @router.namespace 'settings' do
          resource 'avatar'
        end
      end

      it 'recognizes get new' do
        @router.path(:new_settings_avatar).must_equal      '/settings/avatar/new'
        @app.request('GET', '/settings/avatar/new', lint: true).body.must_equal 'Avatar::New'
      end

      it 'recognizes post create' do
        @router.path(:settings_avatar).must_equal              '/settings/avatar'
        @app.request('POST', '/settings/avatar', lint: true).body.must_equal 'Avatar::Create'
      end

      it 'recognizes get show' do
        @router.path(:settings_avatar).must_equal           '/settings/avatar'
        @app.request('GET', '/settings/avatar', lint: true).body.must_equal 'Avatar::Show'
      end

      it 'recognizes get edit' do
        @router.path(:edit_settings_avatar).must_equal      '/settings/avatar/edit'
        @app.request('GET', '/settings/avatar/edit', lint: true).body.must_equal 'Avatar::Edit'
      end

      it 'recognizes patch update' do
        @router.path(:settings_avatar).must_equal               '/settings/avatar'
        @app.request('PATCH', '/settings/avatar', lint: true).body.must_equal 'Avatar::Update'
      end

      it 'recognizes delete destroy' do
        @router.path(:settings_avatar).must_equal                 '/settings/avatar'
        @app.request('DELETE', '/settings/avatar', lint: true).body.must_equal 'Avatar::Destroy'
      end

      describe ':only option' do
        before do
          @router.namespace 'settings' do
            resource 'profile', only: [:edit, :update]
          end
        end

        it 'recognizes only specified paths' do
          @router.path(:edit_settings_profile).must_equal      '/settings/profile/edit'
          @app.request('GET', '/settings/profile/edit', lint: true).body.must_equal 'Profile::Edit'

          @router.path(:settings_profile).must_equal               '/settings/profile'
          @app.request('PATCH', '/settings/profile', lint: true).body.must_equal 'Profile::Update'
        end

        it 'does not recognize other paths' do
          @app.request('GET',    '/settings/profile', lint: true).status.must_equal     405
          @app.request('GET',    '/settings/profile/new', lint: true).status.must_equal 405
          @app.request('POST',   '/settings/profile', lint: true).status.must_equal     405
          @app.request('DELETE', '/settings/profile', lint: true).status.must_equal     405

          exception = -> { @router.path(:new_settings_profile) }.must_raise Hanami::Routing::InvalidRouteException
          exception.message.must_equal 'No route (path) could be generated for :new_settings_profile - please check given arguments'
        end
      end

      describe ':except option' do
        before do
          @router.namespace 'settings' do
            resource 'profile', except: [:edit, :update]
          end
        end

        it 'recognizes only the non-rejected paths' do
          @router.path(:settings_profile).must_equal           '/settings/profile'
          @app.request('GET', '/settings/profile', lint: true).body.must_equal 'Profile::Show'

          @router.path(:new_settings_profile).must_equal      '/settings/profile/new'
          @app.request('GET', '/settings/profile/new', lint: true).body.must_equal 'Profile::New'

          @router.path(:settings_profile).must_equal              '/settings/profile'
          @app.request('POST', '/settings/profile', lint: true).body.must_equal 'Profile::Create'

          @router.path(:settings_profile).must_equal                 '/settings/profile'
          @app.request('DELETE', '/settings/profile', lint: true).body.must_equal 'Profile::Destroy'
        end

        it 'does not recognize other paths' do
          @app.request('GET', '/settings/profile/edit', lint: true).status.must_equal 404

          exception = -> { @router.path(:edit_settings_profile) }.must_raise Hanami::Routing::InvalidRouteException
          exception.message.must_equal 'No route (path) could be generated for :edit_settings_profile - please check given arguments'
        end
      end
    end
  end
end
