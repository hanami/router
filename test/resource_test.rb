require 'test_helper'

describe Lotus::Router do
  before do
    @router = Lotus::Router.new
    @app    = Rack::MockRequest.new(@router)
  end

  after do
    @router.reset!
  end

  describe '#resource' do
    before do
      @router.resource 'avatar'
    end

    it 'recognizes get new' do
      @router.path(:new_avatar).must_equal                '/avatar/new'
      @app.request('GET', '/avatar/new').body.must_equal  'Avatar::New'
    end

    it 'recognizes post create' do
      @router.path(:avatar).must_equal                    '/avatar'
      @app.request('POST', '/avatar').body.must_equal     'Avatar::Create'
    end

    it 'recognizes get show' do
      @router.path(:avatar).must_equal                    '/avatar'
      @app.request('GET', '/avatar').body.must_equal      'Avatar::Show'
    end

    it 'recognizes get edit' do
      @router.path(:edit_avatar).must_equal               '/avatar/edit'
      @app.request('GET', '/avatar/edit').body.must_equal 'Avatar::Edit'
    end

    it 'recognizes patch update' do
      @router.path(:avatar).must_equal                    '/avatar'
      @app.request('PATCH', '/avatar').body.must_equal    'Avatar::Update'
    end

    it 'recognizes delete destroy' do
      @router.path(:avatar).must_equal                    '/avatar'
      @app.request('DELETE', '/avatar').body.must_equal   'Avatar::Destroy'
    end

    describe ':only option' do
      before do
        @router.resource 'profile', only: [:edit, :update]
      end

      it 'recognizes only specified paths' do
        @router.path(:edit_profile).must_equal               '/profile/edit'
        @app.request('GET', '/profile/edit').body.must_equal 'Profile::Edit'

        @router.path(:profile).must_equal                    '/profile'
        @app.request('PATCH', '/profile').body.must_equal    'Profile::Update'
      end

      it 'does not recognize other paths' do
        @app.request('GET',    '/profile/new').status.must_equal 405
        @app.request('POST',   '/profile').status.must_equal     405
        @app.request('GET',    '/profile').status.must_equal     405
        @app.request('DELETE', '/profile').status.must_equal     405

        -> { @router.path(:new_profile) }.must_raise Lotus::Routing::InvalidRouteException
      end
    end

    describe ':except option' do
      before do
        @router.resource 'profile', except: [:new, :show, :create, :destroy]
      end

      it 'recognizes only the non-rejected paths' do
        @router.path(:edit_profile).must_equal               '/profile/edit'
        @app.request('GET', '/profile/edit').body.must_equal 'Profile::Edit'

        @router.path(:profile).must_equal                    '/profile'
        @app.request('PATCH', '/profile').body.must_equal    'Profile::Update'
      end

      it 'does not recognize other paths' do
        @app.request('GET',    '/profile/new').status.must_equal 405
        @app.request('POST',   '/profile').status.must_equal     405
        @app.request('GET',    '/profile').status.must_equal     405
        @app.request('DELETE', '/profile').status.must_equal     405

        -> { @router.path(:new_profile) }.must_raise Lotus::Routing::InvalidRouteException
      end
    end

    describe 'member' do
      before do
        @router.resource 'profile', only: [:new] do
          member do
            patch 'activate'
            patch '/deactivate'
          end
        end
      end

      it 'recognizes the path' do
        @router.path(:activate_profile).must_equal                 '/profile/activate'
        @app.request('PATCH', '/profile/activate').body.must_equal 'Profile::Activate'
      end

      it 'recognizes the path with a leading slash' do
        @router.path(:deactivate_profile).must_equal                 '/profile/deactivate'
        @app.request('PATCH', '/profile/deactivate').body.must_equal 'Profile::Deactivate'
      end
    end

    describe 'collection' do
      before do
        @router.resource 'profile', only: [:new] do
          collection do
            get 'keys'
            get '/activities'
          end
        end
      end

      it 'recognizes the path' do
        @router.path(:keys_profile).must_equal               '/profile/keys'
        @app.request('GET', '/profile/keys').body.must_equal 'Profile::Keys'
      end

      it 'recognizes the path with a leading slash' do
        @router.path(:activities_profile).must_equal               '/profile/activities'
        @app.request('GET', '/profile/activities').body.must_equal 'Profile::Activities'
      end
    end

    describe 'controller' do
      before do
        @router.resource 'profile', controller: 'keys', only: [:new]
      end

      it 'recognizes path with different controller' do
        @router.path(:new_profile).must_equal               '/profile/new'
        @app.request('GET', '/profile/new').body.must_equal 'Keys::New'
      end
    end
  end
end
