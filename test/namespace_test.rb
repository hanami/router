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

  describe '#namespace' do
    it 'recognizes get path' do
      endpoint = endpoint([200, {}, ['Trees (GET)!']])
      @router.namespace 'trees' do
        get '/plane-tree', to: endpoint
      end

      @app.request('GET', '/trees/plane-tree').body.must_equal 'Trees (GET)!'
    end

    it 'recognizes post path' do
      endpoint = endpoint([200, {}, ['Trees (POST)!']])
      @router.namespace 'trees' do
        post '/sequoia', to: endpoint
      end

      @app.request('POST', '/trees/sequoia').body.must_equal 'Trees (POST)!'
    end

    it 'recognizes put path' do
      endpoint = endpoint([200, {}, ['Trees (PUT)!']])
      @router.namespace 'trees' do
        put '/cherry-tree', to: endpoint
      end

      @app.request('PUT', '/trees/cherry-tree').body.must_equal 'Trees (PUT)!'
    end

    it 'recognizes patch path' do
      endpoint = endpoint([200, {}, ['Trees (PATCH)!']])
      @router.namespace 'trees' do
        patch '/cedar', to: endpoint
      end

      @app.request('PATCH', '/trees/cedar').body.must_equal 'Trees (PATCH)!'
    end

    it 'recognizes delete path' do
      endpoint = endpoint([200, {}, ['Trees (DELETE)!']])
      @router.namespace 'trees' do
        delete '/pine', to: endpoint
      end

      @app.request('DELETE', '/trees/pine').body.must_equal 'Trees (DELETE)!'
    end

    it 'recognizes trace path' do
      endpoint = endpoint([200, {}, ['Trees (TRACE)!']])
      @router.namespace 'trees' do
        trace '/cypress', to: endpoint
      end

      @app.request('TRACE', '/trees/cypress').body.must_equal 'Trees (TRACE)!'
    end

    describe 'nested' do
      before do
        endpoint = endpoint([200, {}, ['Meow!']])
        @router.namespace 'animals' do
          namespace 'mammals' do
            get '/cats', to: endpoint
          end
        end
      end

      it 'recognizes get path' do
        @app.request('GET', '/animals/mammals/cats').body.must_equal 'Meow!'
      end
    end

    describe 'redirect' do
      before do
        endpoint = endpoint([200, {}, ['New Home!']])
        @router.namespace 'users' do
          get '/home', to: endpoint
          redirect '/dashboard', to: '/home'
        end
      end

      it 'recognizes get path' do
        @app.request('GET', '/users/dashboard').headers['Location'].must_equal '/users/home'
        @app.request('GET', '/users/dashboard').status.must_equal 302
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
        @app.request('GET', '/vegetals/flowers').body.must_equal         'Flowers::Index'
      end

      it 'recognizes get new' do
        @router.path(:vegetals_new_flowers).must_equal          '/vegetals/flowers/new'
        @app.request('GET', '/vegetals/flowers/new').body.must_equal     'Flowers::New'
      end

      it 'recognizes post create' do
        @router.path(:vegetals_flowers).must_equal                       '/vegetals/flowers'
        @app.request('POST', '/vegetals/flowers').body.must_equal        'Flowers::Create'
      end

      it 'recognizes get show' do
        @router.path(:vegetals_flowers, id: 23).must_equal               '/vegetals/flowers/23'
        @app.request('GET', '/vegetals/flowers/23').body.must_equal      'Flowers::Show 23'
      end

      it 'recognizes get edit' do
        @router.path(:vegetals_edit_flowers, id: 23).must_equal          '/vegetals/flowers/23/edit'
        @app.request('GET', '/vegetals/flowers/23/edit').body.must_equal 'Flowers::Edit 23'
      end

      it 'recognizes patch update' do
        @router.path(:vegetals_flowers, id: 23).must_equal               '/vegetals/flowers/23'
        @app.request('PATCH', '/vegetals/flowers/23').body.must_equal    'Flowers::Update 23'
      end

      it 'recognizes delete destroy' do
        @router.path(:vegetals_flowers, id: 23).must_equal               '/vegetals/flowers/23'
        @app.request('DELETE', '/vegetals/flowers/23').body.must_equal   'Flowers::Destroy 23'
      end

      describe ':only option' do
        before do
          @router.namespace 'electronics' do
            resources 'keyboards', only: [:index, :edit]
          end
        end

        it 'recognizes only specified paths' do
          @router.path(:electronics_keyboards).must_equal                       '/electronics/keyboards'
          @app.request('GET', '/electronics/keyboards').body.must_equal         'Keyboards::Index'

          @router.path(:electronics_edit_keyboards, id: 23).must_equal          '/electronics/keyboards/23/edit'
          @app.request('GET', '/electronics/keyboards/23/edit').body.must_equal 'Keyboards::Edit 23'
        end

        it 'does not recognize other paths' do
          @app.request('GET',    '/electronics/keyboards/new').status.must_equal 404
          @app.request('POST',   '/electronics/keyboards').status.must_equal     405
          @app.request('GET',    '/electronics/keyboards/23').status.must_equal  404
          @app.request('PATCH',  '/electronics/keyboards/23').status.must_equal  405
          @app.request('DELETE', '/electronics/keyboards/23').status.must_equal  405

          -> { @router.path(:electronics_new_keyboards) }.must_raise HttpRouter::InvalidRouteException
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
          @app.request('GET', '/electronics/keyboards').body.must_equal         'Keyboards::Index'

          @router.path(:electronics_edit_keyboards, id: 23).must_equal          '/electronics/keyboards/23/edit'
          @app.request('GET', '/electronics/keyboards/23/edit').body.must_equal 'Keyboards::Edit 23'

          @router.path(:electronics_keyboards).must_equal                       '/electronics/keyboards'
          @app.request('POST', '/electronics/keyboards').body.must_equal        'Keyboards::Create'
        end

        it 'does not recognize other paths' do
          @app.request('GET',    '/electronics/keyboards/new').status.must_equal 404
          @app.request('PATCH',  '/electronics/keyboards/23').status.must_equal  405
          @app.request('DELETE', '/electronics/keyboards/23').status.must_equal  405

          -> { @router.path(:electronics_new_keyboards) }.must_raise HttpRouter::InvalidRouteException
        end
      end
    end
  end
end
