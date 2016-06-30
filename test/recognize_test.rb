require 'test_helper'

describe Hanami::Router do
  describe '#recognize' do
    before do
      @router = Hanami::Router.new(namespace: Web::Controllers) do
        get '/',              to: 'home#index',                       as: :home
        get '/dashboard',     to: Web::Controllers::Dashboard::Index, as: :dashboard
        get '/rack_class',    to: RackMiddleware,                     as: :rack_class
        get '/rack_app',      to: RackMiddlewareInstanceMethod,       as: :rack_app
        get '/proc',          to: ->(env) { [200, {}, ['OK']] },      as: :proc
        get '/resources/:id', to: ->(env) { [200, {}, ['PARAMS']] },  as: :params
      end
    end

    describe 'from Rack env' do
      it 'recognizes proc' do
        env   = Rack::MockRequest.env_for('/proc', method: :get)
        route = @router.recognize(env)

        _, _, body = *route.call({})

        body.must_equal      ['OK']
        route.verb.must_equal 'GET'

        assert route.routable?, "Expected route to be routable"
      end

      it 'recognizes procs with params' do
        env   = Rack::MockRequest.env_for('/resources/1', method: :get)
        route = @router.recognize(env)

        route.params.must_equal(id: "1")
      end

      it 'recognizes action with naming convention (home#index)' do
        env   = Rack::MockRequest.env_for('/', method: :get)
        route = @router.recognize(env)

        _, _, body = *route.call({})

        body.must_equal      ["Hello from Web::Controllers::Home::Index"]
        route.verb.must_equal 'GET'

        route.action.must_equal('home#index')
        assert route.routable?, "Expected route to be routable"
      end

      it 'recognizes action from class' do
        env   = Rack::MockRequest.env_for('/dashboard', method: :get)
        route = @router.recognize(env)

        _, _, body = *route.call({})

        body.must_equal      ["Hello from Web::Controllers::Dashboard::Index"]
        route.verb.must_equal 'GET'

        route.action.must_equal('dashboard#index')
        assert route.routable?, "Expected route to be routable"
      end

      it 'recognizes action from rack middleware class' do
        env   = Rack::MockRequest.env_for('/rack_class', method: :get)
        route = @router.recognize(env)

        _, _, body = *route.call({})

        body.must_equal      ["RackMiddleware"]
        route.verb.must_equal 'GET'

        route.action.must_equal('RackMiddleware')
        assert route.routable?, "Expected route to be routable"
      end

      it 'recognizes action from rack middleware' do
        env   = Rack::MockRequest.env_for('/rack_app', method: :get)
        route = @router.recognize(env)

        _, _, body = *route.call({})

        body.must_equal      ["RackMiddlewareInstanceMethod"]
        route.verb.must_equal 'GET'

        route.action.must_equal('RackMiddlewareInstanceMethod')
        assert route.routable?, "Expected route to be routable"
      end

      it 'returns not routeable result when cannot recognize' do
        env   = Rack::MockRequest.env_for('/', method: :post)
        route = @router.recognize(env)

        assert !route.routable?, "Expected route to NOT be routable"
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

        body.must_equal      ['OK']
        route.verb.must_equal 'GET'

        assert route.routable?, "Expected route to be routable"
      end

      it 'recognizes procs with params' do
        route = @router.recognize('/resources/1')

        route.params.must_equal(id: "1")
      end

      it 'recognizes action with naming convention (home#index)' do
        route = @router.recognize('/')

        _, _, body = *route.call({})

        body.must_equal      ["Hello from Web::Controllers::Home::Index"]
        route.verb.must_equal 'GET'

        route.action.must_equal('home#index')
        assert route.routable?, "Expected route to be routable"
      end

      it 'recognizes action from class' do
        route = @router.recognize('/dashboard')

        _, _, body = *route.call({})

        body.must_equal      ["Hello from Web::Controllers::Dashboard::Index"]
        route.verb.must_equal 'GET'

        route.action.must_equal('dashboard#index')
        assert route.routable?, "Expected route to be routable"
      end

      it 'recognizes action from rack middleware class' do
        route = @router.recognize('/rack_class')

        _, _, body = *route.call({})

        body.must_equal      ["RackMiddleware"]
        route.verb.must_equal 'GET'

        route.action.must_equal('RackMiddleware')
        assert route.routable?, "Expected route to be routable"
      end

      it 'recognizes action from rack middleware' do
        route = @router.recognize('/rack_app')

        _, _, body = *route.call({})

        body.must_equal      ["RackMiddlewareInstanceMethod"]
        route.verb.must_equal 'GET'

        route.action.must_equal('RackMiddlewareInstanceMethod')
        assert route.routable?, "Expected route to be routable"
      end

      it 'returns not routeable result when cannot recognize' do
        route = @router.recognize('/', method: :post)

        assert !route.routable?, "Expected route to NOT be routable"
      end

      it 'raises error if #call is invoked for not routeable object when cannot recognize' do
        env   = Rack::MockRequest.env_for('/', method: :post)
        route = @router.recognize('/', method: :post)

        exception = -> { route.call(env) }.must_raise Hanami::Router::NotRoutableEndpointError
        exception.message.must_equal 'Cannot find routable endpoint for POST "/"'
      end
    end

    describe 'from named path' do
      it 'recognizes proc' do
        route = @router.recognize(:proc)

        _, _, body = *route.call({})

        body.must_equal      ['OK']
        route.verb.must_equal 'GET'

        assert route.routable?, "Expected route to be routable"
      end

      it 'recognizes procs with params' do
        route = @router.recognize(:params, id: 1)

        route.params.must_equal(id: "1")
      end

      it 'recognizes action with naming convention (home#index)' do
        route = @router.recognize(:home)

        _, _, body = *route.call({})

        body.must_equal      ["Hello from Web::Controllers::Home::Index"]
        route.verb.must_equal 'GET'

        route.action.must_equal('home#index')
        assert route.routable?, "Expected route to be routable"
      end

      it 'recognizes action from class' do
        route = @router.recognize(:dashboard)

        _, _, body = *route.call({})

        body.must_equal      ["Hello from Web::Controllers::Dashboard::Index"]
        route.verb.must_equal 'GET'

        route.action.must_equal('dashboard#index')
        assert route.routable?, "Expected route to be routable"
      end

      it 'recognizes action from rack middleware class' do
        route = @router.recognize(:rack_class)

        _, _, body = *route.call({})

        body.must_equal      ["RackMiddleware"]
        route.verb.must_equal 'GET'

        route.action.must_equal('RackMiddleware')
        assert route.routable?, "Expected route to be routable"
      end

      it 'recognizes action from rack middleware' do
        route = @router.recognize(:rack_app)

        _, _, body = *route.call({})

        body.must_equal      ["RackMiddlewareInstanceMethod"]
        route.verb.must_equal 'GET'

        route.action.must_equal('RackMiddlewareInstanceMethod')
        assert route.routable?, "Expected route to be routable"
      end

      it 'returns not routeable result when cannot find named route' do
        route = @router.recognize(:unknown)

        assert !route.routable?, "Expected route to NOT be routable"
      end

      it 'returns not routeable result when cannot recognize' do
        route = @router.recognize(:home, {method: :post}, {})

        assert !route.routable?, "Expected route to NOT be routable"
      end

      it 'raises error if #call is invoked for not routeable object when cannot recognize' do
        env   = Rack::MockRequest.env_for('/', method: :post)
        route = @router.recognize(:home, {method: :post}, {})

        exception = -> { route.call(env) }.must_raise Hanami::Router::NotRoutableEndpointError
        exception.message.must_equal 'Cannot find routable endpoint for POST "/"'
      end
    end
  end

  describe '#recognize' do
    before do
      @router = Hanami::Router.new do
      end
    end

    describe 'without routes' do
      it 'should not fail' do
        route = @router.recognize('/books/1')

        assert_equal '', route.action, 'Expected action to be empty String'
        assert_equal false, route.routable?, 'Expected route to be not routable'
        assert_nil route.params, 'Expected params to be Nil'
      end
    end
  end
end
