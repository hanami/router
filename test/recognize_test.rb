require 'test_helper'

describe Hanami::Router do
  describe '#recognize' do
    before do
      @router = Hanami::Router.new(namespace: Web::Controllers) do
        get '/',              to: 'home#index',                       as: :home
        get '/dashboard',     to: Web::Controllers::Dashboard::Index, as: :dashboard
        get '/rack_class',    to: RackMiddleware,                     as: :rack_class
        get '/rack_app',      to: RackMiddlewareInstanceMethod,       as: :rack_app
        get '/proc',          to: ->(_env) { [200, {}, ['OK']] },     as: :proc
        get '/resources/:id', to: ->(_env) { [200, {}, ['PARAMS']] }, as: :params
      end
    end

    describe 'from Rack env' do
      it 'recognizes proc' do
        env   = Rack::MockRequest.env_for('/proc', method: :get)
        route = @router.recognize(env)

        _, _, body = *route.call({})

        body.must_equal ['OK']

        assert route.routable?, 'Expected route to be routable'
        route.action.must_match 'test/recognize_test.rb:11 (lambda)'
        route.verb.must_equal   'GET'
        route.path.must_equal   '/proc'
        route.params.must_equal({})
      end

      it 'recognizes procs with params' do
        env   = Rack::MockRequest.env_for('/resources/1', method: :get)
        route = @router.recognize(env)

        assert route.routable?, 'Expected route to be routable'
        route.action.must_match 'test/recognize_test.rb:12 (lambda)'
        route.verb.must_equal   'GET'
        route.path.must_equal   '/resources/1'
        route.params.must_equal(id: '1')
      end

      it 'recognizes action with naming convention (home#index)' do
        env   = Rack::MockRequest.env_for('/', method: :get)
        route = @router.recognize(env)

        _, _, body = *route.call({})

        body.must_equal ['Hello from Web::Controllers::Home::Index']

        assert route.routable?, 'Expected route to be routable'
        route.action.must_equal 'home#index'
        route.verb.must_equal   'GET'
        route.path.must_equal   '/'
        route.params.must_equal({})
      end

      it 'recognizes action from class' do
        env   = Rack::MockRequest.env_for('/dashboard', method: :get)
        route = @router.recognize(env)

        _, _, body = *route.call({})

        body.must_equal ['Hello from Web::Controllers::Dashboard::Index']

        assert route.routable?, 'Expected route to be routable'
        route.action.must_equal 'dashboard#index'
        route.verb.must_equal   'GET'
        route.path.must_equal   '/dashboard'
        route.params.must_equal({})
      end

      it 'recognizes action from rack middleware class' do
        env   = Rack::MockRequest.env_for('/rack_class', method: :get)
        route = @router.recognize(env)

        _, _, body = *route.call({})

        body.must_equal ['RackMiddleware']

        assert route.routable?, 'Expected route to be routable'
        route.action.must_equal 'RackMiddleware'
        route.verb.must_equal   'GET'
        route.path.must_equal   '/rack_class'
        route.params.must_equal({})
      end

      it 'recognizes action from rack middleware' do
        env   = Rack::MockRequest.env_for('/rack_app', method: :get)
        route = @router.recognize(env)

        _, _, body = *route.call({})

        body.must_equal ['RackMiddlewareInstanceMethod']

        assert route.routable?, 'Expected route to be routable'
        route.action.must_equal 'RackMiddlewareInstanceMethod'
        route.verb.must_equal   'GET'
        route.path.must_equal   '/rack_app'
        route.params.must_equal({})
      end

      it 'returns not routeable result when cannot recognize' do
        env   = Rack::MockRequest.env_for('/', method: :post)
        route = @router.recognize(env)

        assert !route.routable?, 'Expected route to NOT be routable'
        route.action.must_be_nil
        route.verb.must_equal   'POST'
        route.path.must_equal   '/'
        route.params.must_equal({})
      end

      it 'raises error if #call is invoked for not routeable object when cannot recognize' do
        env   = Rack::MockRequest.env_for('/', method: :post)
        route = @router.recognize(env)

        exception = -> { route.call(env) }.must_raise Hanami::Router::NotRoutableEndpointError
        exception.message.must_equal 'Cannot find routable endpoint for POST "/"'
      end
    end

    describe 'from path' do
      it 'recognizes proc' do
        route = @router.recognize('/proc')

        _, _, body = *route.call({})

        body.must_equal ['OK']

        assert route.routable?, 'Expected route to be routable'
        route.action.must_match 'test/recognize_test.rb:11 (lambda)'
        route.verb.must_equal   'GET'
        route.path.must_equal   '/proc'
        route.params.must_equal({})
      end

      it 'recognizes procs with params' do
        route = @router.recognize('/resources/1')

        assert route.routable?, 'Expected route to be routable'
        route.action.must_match 'test/recognize_test.rb:12 (lambda)'
        route.verb.must_equal   'GET'
        route.path.must_equal   '/resources/1'
        route.params.must_equal(id: '1')
      end

      it 'recognizes action with naming convention (home#index)' do
        route = @router.recognize('/')

        _, _, body = *route.call({})

        body.must_equal ['Hello from Web::Controllers::Home::Index']

        assert route.routable?, 'Expected route to be routable'
        route.action.must_equal 'home#index'
        route.verb.must_equal   'GET'
        route.path.must_equal   '/'
        route.params.must_equal({})
      end

      it 'recognizes action from class' do
        route = @router.recognize('/dashboard')

        _, _, body = *route.call({})

        body.must_equal ['Hello from Web::Controllers::Dashboard::Index']

        assert route.routable?, 'Expected route to be routable'
        route.action.must_equal 'dashboard#index'
        route.verb.must_equal   'GET'
        route.path.must_equal   '/dashboard'
        route.params.must_equal({})
      end

      it 'recognizes action from rack middleware class' do
        route = @router.recognize('/rack_class')

        _, _, body = *route.call({})

        body.must_equal ['RackMiddleware']

        assert route.routable?, 'Expected route to be routable'
        route.action.must_equal 'RackMiddleware'
        route.verb.must_equal   'GET'
        route.path.must_equal   '/rack_class'
        route.params.must_equal({})
      end

      it 'recognizes action from rack middleware' do
        route = @router.recognize('/rack_app')

        _, _, body = *route.call({})

        body.must_equal ['RackMiddlewareInstanceMethod']

        assert route.routable?, 'Expected route to be routable'
        route.action.must_equal 'RackMiddlewareInstanceMethod'
        route.verb.must_equal   'GET'
        route.path.must_equal   '/rack_app'
        route.params.must_equal({})
      end

      it 'returns not routeable result when cannot recognize' do
        route = @router.recognize('/', method: :post)

        assert !route.routable?, 'Expected route to NOT be routable'
        route.action.must_be_nil
        route.verb.must_equal    'POST'
        route.path.must_equal    '/'
        route.params.must_equal({})
      end

      it 'raises error if #call is invoked for not routeable object when cannot recognize' do
        env   = Rack::MockRequest.env_for('/', method: :post)
        route = @router.recognize('/', method: :post)

        exception = -> { route.call(env) }.must_raise Hanami::Router::NotRoutableEndpointError
        exception.message.must_equal 'Cannot find routable endpoint for POST "/"'
      end

      it 'raises error if #call is invoked for unknown path' do
        route = @router.recognize('/unknown')

        assert !route.routable?, 'Expected route to NOT be routable'
        route.action.must_be_nil
        route.verb.must_equal    'GET'
        route.path.must_equal    '/unknown'
        route.params.must_equal({})

        exception = -> { route.call({}) }.must_raise Hanami::Router::NotRoutableEndpointError
        exception.message.must_equal 'Cannot find routable endpoint for GET "/unknown"'
      end
    end

    describe 'from named path' do
      it 'recognizes proc' do
        route = @router.recognize(:proc)

        _, _, body = *route.call({})

        body.must_equal ['OK']

        assert route.routable?, 'Expected route to be routable'
        route.action.must_match 'test/recognize_test.rb:11 (lambda)'
        route.verb.must_equal   'GET'
        route.path.must_equal   '/proc'
        route.params.must_equal({})
      end

      it 'recognizes procs with params' do
        route = @router.recognize(:params, id: 1)

        assert route.routable?, 'Expected route to be routable'
        route.action.must_match 'test/recognize_test.rb:12 (lambda)'
        route.verb.must_equal   'GET'
        route.path.must_equal   '/resources/1'
        route.params.must_equal(id: '1')
      end

      it 'recognizes action with naming convention (home#index)' do
        route = @router.recognize(:home)

        _, _, body = *route.call({})

        body.must_equal ['Hello from Web::Controllers::Home::Index']

        assert route.routable?, 'Expected route to be routable'
        route.action.must_equal 'home#index'
        route.verb.must_equal   'GET'
        route.path.must_equal   '/'
        route.params.must_equal({})
      end

      it 'recognizes action from class' do
        route = @router.recognize(:dashboard)

        _, _, body = *route.call({})

        body.must_equal ['Hello from Web::Controllers::Dashboard::Index']

        assert route.routable?, 'Expected route to be routable'
        route.action.must_equal 'dashboard#index'
        route.verb.must_equal   'GET'
        route.path.must_equal   '/dashboard'
        route.params.must_equal({})
      end

      it 'recognizes action from rack middleware class' do
        route = @router.recognize(:rack_class)

        _, _, body = *route.call({})

        body.must_equal ['RackMiddleware']

        assert route.routable?, 'Expected route to be routable'
        route.action.must_equal 'RackMiddleware'
        route.verb.must_equal   'GET'
        route.path.must_equal   '/rack_class'
        route.params.must_equal({})
      end

      it 'recognizes action from rack middleware' do
        route = @router.recognize(:rack_app)

        _, _, body = *route.call({})

        body.must_equal ['RackMiddlewareInstanceMethod']

        assert route.routable?, 'Expected route to be routable'
        route.action.must_equal 'RackMiddlewareInstanceMethod'
        route.verb.must_equal   'GET'
        route.path.must_equal   '/rack_app'
        route.params.must_equal({})
      end

      it 'returns not routeable result when cannot find named route' do
        route = @router.recognize(:unknown)

        assert !route.routable?, 'Expected route to NOT be routable'
        route.action.must_be_nil
        route.verb.must_be_nil
        route.path.must_be_nil
        route.params.must_equal({})
      end

      it 'returns not routeable result when cannot recognize' do
        route = @router.recognize(:home, { method: :post }, {})

        assert !route.routable?, 'Expected route to NOT be routable'
        route.action.must_be_nil
        route.verb.must_equal    'POST'
        route.path.must_equal    '/'
        route.params.must_equal({})
      end

      it 'raises error if #call is invoked for not routeable object when cannot recognize' do
        env   = Rack::MockRequest.env_for('/', method: :post)
        route = @router.recognize(:home, { method: :post }, {})

        exception = -> { route.call(env) }.must_raise Hanami::Router::NotRoutableEndpointError
        exception.message.must_equal 'Cannot find routable endpoint for POST "/"'
      end
    end
  end
end
