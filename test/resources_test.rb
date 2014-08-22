require 'test_helper'

describe Lotus::Router do
  before do
    @router = Lotus::Router.new
    @app    = Rack::MockRequest.new(@router)
  end

  after do
    @router.reset!
  end

  def endpoint(response)
    ->(env) { response }
  end

  describe '#resources' do
    before do
      @router.resources 'flowers'
    end

    it 'recognizes get index' do
      @router.path(:flowers).must_equal                       '/flowers'
      @app.request('GET', '/flowers').body.must_equal         'Flowers::Index'
    end

    it 'recognizes get new' do
      @router.path(:new_flowers).must_equal                   '/flowers/new'
      @app.request('GET', '/flowers/new').body.must_equal     'Flowers::New'
    end

    it 'recognizes post create' do
      @router.path(:flowers).must_equal                       '/flowers'
      @app.request('POST', '/flowers').body.must_equal        'Flowers::Create'
    end

    it 'recognizes get show' do
      @router.path(:flowers, id: 23).must_equal               '/flowers/23'
      @app.request('GET', '/flowers/23').body.must_equal      'Flowers::Show 23'
    end

    it 'recognizes get edit' do
      @router.path(:edit_flowers, id: 23).must_equal          '/flowers/23/edit'
      @app.request('GET', '/flowers/23/edit').body.must_equal 'Flowers::Edit 23'
    end

    it 'recognizes patch update' do
      @router.path(:flowers, id: 23).must_equal               '/flowers/23'
      @app.request('PATCH', '/flowers/23').body.must_equal    'Flowers::Update 23'
    end

    it 'recognizes delete destroy' do
      @router.path(:flowers, id: 23).must_equal               '/flowers/23'
      @app.request('DELETE', '/flowers/23').body.must_equal   'Flowers::Destroy 23'
    end

    describe ':only option' do
      before do
        @router.resources 'keyboards', only: [:index, :edit]
      end

      it 'recognizes only specified paths' do
        @router.path(:keyboards).must_equal                       '/keyboards'
        @app.request('GET', '/keyboards').body.must_equal         'Keyboards::Index'

        @router.path(:edit_keyboards, id: 23).must_equal          '/keyboards/23/edit'
        @app.request('GET', '/keyboards/23/edit').body.must_equal 'Keyboards::Edit 23'
      end

      it 'does not recognize other paths' do
        @app.request('GET',    '/keyboards/new').status.must_equal 404
        @app.request('POST',   '/keyboards').status.must_equal     405
        @app.request('GET',    '/keyboards/23').status.must_equal  404
        @app.request('PATCH',  '/keyboards/23').status.must_equal  405
        @app.request('DELETE', '/keyboards/23').status.must_equal  405

        -> { @router.path(:new_keyboards) }.must_raise HttpRouter::InvalidRouteException
      end
    end

    describe ':except option' do
      before do
        @router.resources 'keyboards', except: [:new, :show, :update, :destroy]
      end

      it 'recognizes only the non-rejected paths' do
        @router.path(:keyboards).must_equal                       '/keyboards'
        @app.request('GET', '/keyboards').body.must_equal         'Keyboards::Index'

        @router.path(:edit_keyboards, id: 23).must_equal          '/keyboards/23/edit'
        @app.request('GET', '/keyboards/23/edit').body.must_equal 'Keyboards::Edit 23'

        @router.path(:keyboards).must_equal                       '/keyboards'
        @app.request('POST', '/keyboards').body.must_equal        'Keyboards::Create'
      end

      it 'does not recognize other paths' do
        @app.request('GET',    '/keyboards/new').status.must_equal 404
        @app.request('PATCH',  '/keyboards/23').status.must_equal  405
        @app.request('DELETE', '/keyboards/23').status.must_equal  405

        -> { @router.path(:new_keyboards) }.must_raise HttpRouter::InvalidRouteException
      end
    end

    describe 'member' do
      before do
        @router.resources 'keyboards', only: [:show] do
          member do
            get 'screenshot'
          end
        end
      end

      it 'recognizes the path' do
        @router.path(:screenshot_keyboards, id: 23).must_equal          '/keyboards/23/screenshot'
        @app.request('GET', '/keyboards/23/screenshot').body.must_equal 'Keyboards::Screenshot 23'
      end
    end

    describe 'collection' do
      before do
        @router.resources 'keyboards', only: [:show] do
          collection do
            get 'search'
          end
        end
      end

      it 'recognizes the path' do
        @router.path(:search_keyboards).must_equal               '/keyboards/search'
        @app.request('GET', '/keyboards/search').body.must_equal 'Keyboards::Search'
      end
    end
  end
end
