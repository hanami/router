RSpec.describe Hanami::Router do
  before do
    @router = Hanami::Router.new
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
      expect(@router.path(:new_avatar)).to eq(                          '/avatar/new')
      expect(@app.request('GET', '/avatar/new', lint: true).body).to eq('Avatar::New')
    end

    it 'recognizes post create' do
      expect(@router.path(:avatar)).to eq(                           '/avatar')
      expect(@app.request('POST', '/avatar', lint: true).body).to eq('Avatar::Create')
    end

    it 'recognizes get show' do
      expect(@router.path(:avatar)).to eq(                          '/avatar')
      expect(@app.request('GET', '/avatar', lint: true).body).to eq('Avatar::Show')
    end

    it 'recognizes get edit' do
      expect(@router.path(:edit_avatar)).to eq(                          '/avatar/edit')
      expect(@app.request('GET', '/avatar/edit', lint: true).body).to eq('Avatar::Edit')
    end

    it 'recognizes patch update' do
      expect(@router.path(:avatar)).to eq(                            '/avatar')
      expect(@app.request('PATCH', '/avatar', lint: true).body).to eq('Avatar::Update')
    end

    it 'recognizes delete destroy' do
      expect(@router.path(:avatar)).to eq(                             '/avatar')
      expect(@app.request('DELETE', '/avatar', lint: true).body).to eq('Avatar::Destroy')
    end

    describe ':only option' do
      before do
        @router.resource 'profile', only: [:edit, :update]
      end

      it 'recognizes only specified paths' do
        expect(@router.path(:edit_profile)).to eq(                          '/profile/edit')
        expect(@app.request('GET', '/profile/edit', lint: true).body).to eq('Profile::Edit')

        expect(@router.path(:profile)).to eq(                            '/profile')
        expect(@app.request('PATCH', '/profile', lint: true).body).to eq('Profile::Update')
      end

      it 'does not recognize other paths' do
        expect(@app.request('GET',    '/profile/new', lint: true).status).to eq(405)
        expect(@app.request('POST',   '/profile', lint: true).status).to eq(    405)
        expect(@app.request('GET',    '/profile', lint: true).status).to eq(    405)
        expect(@app.request('DELETE', '/profile', lint: true).status).to eq(    405)

        expect { @router.path(:new_profile) }.to raise_error(Hanami::Routing::InvalidRouteException, 'No route (path) could be generated for :new_profile - please check given arguments')
       end
    end

    describe ':except option' do
      before do
        @router.resource 'profile', except: [:new, :show, :create, :destroy]
      end

      it 'recognizes only the non-rejected paths' do
        expect(@router.path(:edit_profile)).to eq(                          '/profile/edit')
        expect(@app.request('GET', '/profile/edit', lint: true).body).to eq('Profile::Edit')

        expect(@router.path(:profile)).to eq(                            '/profile')
        expect(@app.request('PATCH', '/profile', lint: true).body).to eq('Profile::Update')
      end

      it 'does not recognize other paths' do
        expect(@app.request('GET',    '/profile/new', lint: true).status).to eq(405)
        expect(@app.request('POST',   '/profile', lint: true).status).to eq(    405)
        expect(@app.request('GET',    '/profile', lint: true).status).to eq(    405)
        expect(@app.request('DELETE', '/profile', lint: true).status).to eq(    405)

        expect { @router.path(:new_profile) }.to raise_error(Hanami::Routing::InvalidRouteException, 'No route (path) could be generated for :new_profile - please check given arguments')
        
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
        expect(@router.path(:activate_profile)).to eq(                            '/profile/activate')
        expect(@app.request('PATCH', '/profile/activate', lint: true).body).to eq('Profile::Activate')
      end

      it 'recognizes the path with a leading slash' do
        expect(@router.path(:deactivate_profile)).to eq(                            '/profile/deactivate')
        expect(@app.request('PATCH', '/profile/deactivate', lint: true).body).to eq('Profile::Deactivate')
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
        expect(@router.path(:keys_profile)).to eq(                          '/profile/keys')
        expect(@app.request('GET', '/profile/keys', lint: true).body).to eq('Profile::Keys')
      end

      it 'recognizes the path with a leading slash' do
        expect(@router.path(:activities_profile)).to eq(                          '/profile/activities')
        expect(@app.request('GET', '/profile/activities', lint: true).body).to eq('Profile::Activities')
      end
    end

    describe 'controller' do
      before do
        @router.resource 'profile', controller: 'keys', only: [:new]
      end

      it 'recognizes path with different controller' do
        expect(@router.path(:new_profile)).to eq(                          '/profile/new')
        expect(@app.request('GET', '/profile/new', lint: true).body).to eq('Keys::New')
      end
    end

    describe ':as option' do
      before do
        @router.resource 'keyboard', as: 'piano' do
          collection do
            get 'search'
          end

          member do
            get 'screenshot'
          end
        end
      end

      it 'recognizes the new name' do
        expect(@router.path(:piano)).to eq('/keyboard')
        expect(@router.path(:new_piano)).to eq('/keyboard/new')
        expect(@router.path(:edit_piano)).to eq('/keyboard/edit')
        expect(@router.path(:search_piano)).to eq('/keyboard/search')
        expect(@router.path(:screenshot_piano)).to eq('/keyboard/screenshot')
      end

      it 'does not recognize the resource name' do
        e = Hanami::Routing::Hanami::Routing::InvalidRouteException
        expect { @router.path(:keyboard) }.to raise_error( e)
        expect { @router.path(:new_keyboard) }.to raise_error( e)
        expect { @router.path(:edit_keyboard) }.to raise_error( e)
        expect { @router.path(:search_keyboard) }.to raise_error( e)
        expect { @router.path(:screenshot_keyboard) }.to raise_error( e)
      end
    end
  end
end
