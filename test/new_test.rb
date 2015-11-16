require 'test_helper'

describe Lotus::Router do
  describe '.new' do
    before do
      class MockRoute
      end

      endpoint = ->(env) { [200, {}, ['']] }
      @router = Lotus::Router.new do
        get '/route',       to: endpoint
        get '/named_route', to: endpoint, as: :named_route
        resource  'avatar'
        resources 'flowers'
        namespace 'admin' do
          get '/dashboard', to: endpoint
        end
      end

      @app = Rack::MockRequest.new(@router)
    end

    it 'returns instance of Lotus::Router with empty block' do
      router = Lotus::Router.new { }
      router.must_be_instance_of Lotus::Router
    end

    it 'evaluates routes passed from Lotus::Router.define' do
      routes = Lotus::Router.define { post '/domains', to: ->(env) {[201, {}, ['Domain Created']]} }
      router = Lotus::Router.new(&routes)

      app      = Rack::MockRequest.new(router)
      response = app.post('/domains', lint: true)

      response.status.must_equal 201
      response.body.must_equal   'Domain Created'
    end

    it 'returns instance of Lotus::Router' do
      @router.must_be_instance_of Lotus::Router
    end

    it 'sets options' do
      router = Lotus::Router.new(scheme: 'https') do
        get '/', to: ->(env) { }, as: :root
      end

      router.url(:root).must_match('https')
    end

    it 'sets custom separator' do
      router = Lotus::Router.new(action_separator: '^')
      route  = router.get('/', to: 'test^show', as: :root)

      route.dest.must_equal(Test::Show)
    end

    it 'checks if there are defined routes' do
      router = Lotus::Router.new
      router.wont_be :defined?

      router = Lotus::Router.new { get '/', to: ->(env) { } }
      router.must_be :defined?
    end

    it 'recognizes path' do
      @app.get('/route', lint: true).status.must_equal 200
    end

    it 'recognizes named path' do
      @app.get('/named_route', lint: true).status.must_equal 200
    end

    it 'recognizes resource' do
      @app.get('/avatar', lint: true).status.must_equal 200
    end

    it 'recognizes resources' do
      @app.get('/avatar', lint: true).status.must_equal 200
    end

    it 'recognizes namespaced path' do
      @app.get('/admin/dashboard', lint: true).status.must_equal 200
    end
  end
end
