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
        get '/missing',       to: "missing#index",                    as: :missing
      end
    end

    describe 'from Rack env' do
      it 'recognizes proc' do
        env   = Rack::MockRequest.env_for('/proc', method: :get)
        route = @router.recognize(env)

        _, _, body = *route.call({})

        expect(body).to eq( ['OK'])

        assert route.routable?, 'Expected route to be routable'
        expect(route.action.to match( 'test/recognize_test.rb:11 (lambda)')
        expect(route.verb).to eq(   'GET')
        expect(route.path).to eq(   '/proc')
        expect(route.params).to eq({}))
      end

      it 'recognizes procs with params' do
        env   = Rack::MockRequest.env_for('/resources/1', method: :get)
        route = @router.recognize(env)

        assert route.routable?, 'Expected route to be routable'
        expect(route.action.to match( 'test/recognize_test.rb:12 (lambda)')
        expect(route.verb).to eq(   'GET')
        expect(route.path).to eq(   '/resources/1')
        expect(route.params).to eq(id: '1'))
      end

      it 'recognizes action with naming convention (home#index)' do
        env   = Rack::MockRequest.env_for('/', method: :get)
        route = @router.recognize(env)

        _, _, body = *route.call({})

        expect(body).to eq( ['Hello from Web::Controllers::Home::Index'])

        assert route.routable?, 'Expected route to be routable'
        expect(route.action).to eq( 'home#index')
        expect(route.verb).to eq(   'GET')
        expect(route.path).to eq(   '/')
        expect(route.params).to eq({}))
      end

      it 'recognizes action from class' do
        env   = Rack::MockRequest.env_for('/dashboard', method: :get)
        route = @router.recognize(env)

        _, _, body = *route.call({})

        expect(body).to eq( ['Hello from Web::Controllers::Dashboard::Index'])

        assert route.routable?, 'Expected route to be routable'
        expect(route.action).to eq( 'dashboard#index')
        expect(route.verb).to eq(   'GET')
        expect(route.path).to eq(   '/dashboard')
        expect(route.params).to eq({}))
      end

      it 'recognizes action from rack middleware class' do
        env   = Rack::MockRequest.env_for('/rack_class', method: :get)
        route = @router.recognize(env)

        _, _, body = *route.call({})

        expect(body).to eq( ['RackMiddleware'])

        assert route.routable?, 'Expected route to be routable'
        expect(route.action).to eq( 'RackMiddleware')
        expect(route.verb).to eq(   'GET')
        expect(route.path).to eq(   '/rack_class')
        expect(route.params).to eq({}))
      end

      it 'recognizes action from rack middleware' do
        env   = Rack::MockRequest.env_for('/rack_app', method: :get)
        route = @router.recognize(env)

        _, _, body = *route.call({})

        expect(body).to eq( ['RackMiddlewareInstanceMethod'])

        assert route.routable?, 'Expected route to be routable'
        expect(route.action).to eq( 'RackMiddlewareInstanceMethod')
        expect(route.verb).to eq(   'GET')
        expect(route.path).to eq(   '/rack_app')
        expect(route.params).to eq({}))
      end

      it 'returns not routeable result when cannot recognize' do
        env   = Rack::MockRequest.env_for('/', method: :post)
        route = @router.recognize(env)

        assert !route.routable?, 'Expected route to NOT be routable'
        route.action.must_be_nil
        expect(route.verb).to eq(   'POST')
        expect(route.path).to eq(   '/')
        expect(route.params).to eq({}))
      end

      it "returns not routeable result when the lazy endpoint doesn't correspond to an action" do
        env   = Rack::MockRequest.env_for('/missing', method: :get)
        route = @router.recognize(env)

        assert !route.routable?, 'Expected route to NOT be routable'
        route.action.must_be_nil
        expect(route.verb).to eq(   'GET')
        expect(route.path).to eq(   '/missing')
        expect(route.params).to eq({})
      end

      it 'raises error if #call is invoked for not routeable object when cannot recognize' do
        env   = Rack::MockRequest.env_for('/', method: :post)
        route = @router.recognize(env)

        exception = -> { route.call(env) }.must_raise Hanami::Router::NotRoutableEndpointError
        expect(exception.message).to eq( 'Cannot find routable endpoint for POST "/"')
      end
    end

    describe 'from path' do
      it 'recognizes proc' do
        route = @router.recognize('/proc')

        _, _, body = *route.call({})

        expect(body).to eq( ['OK'])

        assert route.routable?, 'Expected route to be routable'
        expect(route.action.to match( 'test/recognize_test.rb:11 (lambda)')
        expect(route.verb).to eq(   'GET')
        expect(route.path).to eq(   '/proc')
        expect(route.params).to eq({}))
      end

      it 'recognizes procs with params' do
        route = @router.recognize('/resources/1')

        assert route.routable?, 'Expected route to be routable'
        expect(route.action.to match( 'test/recognize_test.rb:12 (lambda)')
        expect(route.verb).to eq(   'GET')
        expect(route.path).to eq(   '/resources/1')
        expect(route.params).to eq(id: '1'))
      end

      it 'recognizes action with naming convention (home#index)' do
        route = @router.recognize('/')

        _, _, body = *route.call({})

        expect(body).to eq( ['Hello from Web::Controllers::Home::Index'])

        assert route.routable?, 'Expected route to be routable'
        expect(route.action).to eq( 'home#index')
        expect(route.verb).to eq(   'GET')
        expect(route.path).to eq(   '/')
        expect(route.params).to eq({}))
      end

      it 'recognizes action from class' do
        route = @router.recognize('/dashboard')

        _, _, body = *route.call({})

        expect(body).to eq( ['Hello from Web::Controllers::Dashboard::Index'])

        assert route.routable?, 'Expected route to be routable'
        expect(route.action).to eq( 'dashboard#index')
        expect(route.verb).to eq(   'GET')
        expect(route.path).to eq(   '/dashboard')
        expect(route.params).to eq({}))
      end

      it 'recognizes action from rack middleware class' do
        route = @router.recognize('/rack_class')

        _, _, body = *route.call({})

        expect(body).to eq( ['RackMiddleware'])

        assert route.routable?, 'Expected route to be routable'
        expect(route.action).to eq( 'RackMiddleware')
        expect(route.verb).to eq(   'GET')
        expect(route.path).to eq(   '/rack_class')
        expect(route.params).to eq({}))
      end

      it 'recognizes action from rack middleware' do
        route = @router.recognize('/rack_app')

        _, _, body = *route.call({})

        expect(body).to eq( ['RackMiddlewareInstanceMethod'])

        assert route.routable?, 'Expected route to be routable'
        expect(route.action).to eq( 'RackMiddlewareInstanceMethod')
        expect(route.verb).to eq(   'GET')
        expect(route.path).to eq(   '/rack_app')
        expect(route.params).to eq({}))
      end

      it 'returns not routeable result when cannot recognize' do
        route = @router.recognize('/', method: :post)

        assert !route.routable?, 'Expected route to NOT be routable'
        route.action.must_be_nil
        expect(route.verb).to eq(    'POST')
        expect(route.path).to eq(    '/')
        expect(route.params).to eq({}))
      end

      it "returns not routeable result when the lazy endpoint doesn't correspond to an action" do
        route = @router.recognize('/missing')

        assert !route.routable?, 'Expected route to NOT be routable'
        route.action.must_be_nil
        expect(route.verb).to eq(   'GET')
        expect(route.path).to eq(   '/missing')
        expect(route.params).to eq({}))
      end

      it 'raises error if #call is invoked for not routeable object when cannot recognize' do
        env   = Rack::MockRequest.env_for('/', method: :post)
        route = @router.recognize('/', method: :post)

        exception = -> { route.call(env) }.must_raise Hanami::Router::NotRoutableEndpointError
        expect(exception.message).to eq( 'Cannot find routable endpoint for POST "/"')
      end

      it 'raises error if #call is invoked for unknown path' do
        route = @router.recognize('/unknown')

        assert !route.routable?, 'Expected route to NOT be routable'
        route.action.must_be_nil
        expect(route.verb).to eq(    'GET')
        expect(route.path).to eq(    '/unknown')
        expect(route.params).to eq({}))

        exception = -> { route.call({}) }.must_raise Hanami::Router::NotRoutableEndpointError
        expect(exception.message).to eq( 'Cannot find routable endpoint for GET "/unknown"')
      end
    end

    describe 'from named path' do
      it 'recognizes proc' do
        route = @router.recognize(:proc)

        _, _, body = *route.call({})

        expect(body).to eq( ['OK'])

        assert route.routable?, 'Expected route to be routable'
        expect(route.action.to match( 'test/recognize_test.rb:11 (lambda)')
        expect(route.verb).to eq(   'GET')
        expect(route.path).to eq(   '/proc')
        expect(route.params).to eq({}))
      end

      it 'recognizes procs with params' do
        route = @router.recognize(:params, id: 1)

        assert route.routable?, 'Expected route to be routable'
        expect(route.action.to match( 'test/recognize_test.rb:12 (lambda)')
        expect(route.verb).to eq(   'GET')
        expect(route.path).to eq(   '/resources/1')
        expect(route.params).to eq(id: '1'))
      end

      it 'recognizes action with naming convention (home#index)' do
        route = @router.recognize(:home)

        _, _, body = *route.call({})

        expect(body).to eq( ['Hello from Web::Controllers::Home::Index'])

        assert route.routable?, 'Expected route to be routable'
        expect(route.action).to eq( 'home#index')
        expect(route.verb).to eq(   'GET')
        expect(route.path).to eq(   '/')
        expect(route.params).to eq({}))
      end

      it 'recognizes action from class' do
        route = @router.recognize(:dashboard)

        _, _, body = *route.call({})

        expect(body).to eq( ['Hello from Web::Controllers::Dashboard::Index'])

        assert route.routable?, 'Expected route to be routable'
        expect(route.action).to eq( 'dashboard#index')
        expect(route.verb).to eq(   'GET')
        expect(route.path).to eq(   '/dashboard')
        expect(route.params).to eq({}))
      end

      it 'recognizes action from rack middleware class' do
        route = @router.recognize(:rack_class)

        _, _, body = *route.call({})

        expect(body).to eq( ['RackMiddleware'])

        assert route.routable?, 'Expected route to be routable'
        expect(route.action).to eq( 'RackMiddleware')
        expect(route.verb).to eq(   'GET')
        expect(route.path).to eq(   '/rack_class')
        expect(route.params).to eq({}))
      end

      it 'recognizes action from rack middleware' do
        route = @router.recognize(:rack_app)

        _, _, body = *route.call({})

        expect(body).to eq( ['RackMiddlewareInstanceMethod'])

        assert route.routable?, 'Expected route to be routable'
        expect(route.action).to eq( 'RackMiddlewareInstanceMethod')
        expect(route.verb).to eq(   'GET')
        expect(route.path).to eq(   '/rack_app')
        expect(route.params).to eq({}))
      end

      it 'returns not routeable result when cannot find named route' do
        route = @router.recognize(:unknown)

        assert !route.routable?, 'Expected route to NOT be routable'
        route.action.must_be_nil
        route.verb.must_be_nil
        route.path.must_be_nil
        expect(route.params).to eq({}))
      end

      it 'returns not routeable result when cannot recognize' do
        route = @router.recognize(:home, { method: :post }, {})

        assert !route.routable?, 'Expected route to NOT be routable'
        route.action.must_be_nil
        expect(route.verb).to eq(    'POST')
        expect(route.path).to eq(    '/')
        expect(route.params).to eq({}))
      end

      it "returns not routeable result when the lazy endpoint doesn't correspond to an action" do
        route = @router.recognize(:missing)

        assert !route.routable?, 'Expected route to NOT be routable'
        route.action.must_be_nil
        expect(route.verb).to eq(   'GET')
        expect(route.path).to eq(   '/missing')
        expect(route.params).to eq({}))
      end

      it 'raises error if #call is invoked for not routeable object when cannot recognize' do
        env   = Rack::MockRequest.env_for('/', method: :post)
        route = @router.recognize(:home, { method: :post }, {})

        exception = -> { route.call(env) }.must_raise Hanami::Router::NotRoutableEndpointError
        expect(exception.message).to eq( 'Cannot find routable endpoint for POST "/"')
      end
    end
  end
end
