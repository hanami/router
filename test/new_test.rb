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

      route.dest.must_equal(TestController::Show)
    end

    it 'recognizes path' do
      @app.get('/route').status.must_equal 200
    end

    it 'recognizes named path' do
      @app.get('/named_route').status.must_equal 200
    end

    it 'recognizes resource' do
      @app.get('/avatar').status.must_equal 200
    end

    it 'recognizes resources' do
      @app.get('/avatar').status.must_equal 200
    end

    it 'recognizes namespaced path' do
      @app.get('/admin/dashboard').status.must_equal 200
    end
  end
end
