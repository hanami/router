RSpec.describe Hanami::Router do
  describe '.new' do
    before do
      class MockRoute
      end

      endpoint = ->(env) { [200, {}, ['']] }
      @router = Hanami::Router.new do
        root                to: endpoint
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

    it 'returns instance of Hanami::Router with empty block' do
      router = Hanami::Router.new { }
      expect(router).to be_instance_of(Hanami::Router)
    end

    it 'evaluates routes passed from Hanami::Router.define' do
      routes = Hanami::Router.define { post '/domains', to: ->(env) {[201, {}, ['Domain Created']]} }
      router = Hanami::Router.new(&routes)

      app      = Rack::MockRequest.new(router)
      response = app.post('/domains', lint: true)

      expect(response.status).to eq(201)
      expect(response.body).to eq('Domain Created')
    end

    it 'returns instance of Hanami::Router' do
      expect(@router).to be_instance_of(Hanami::Router)
    end

    it 'sets options' do
      router = Hanami::Router.new(scheme: 'https') do
        root to: ->(env) { }
      end 

      expect(router.url(:root)).to match('https')
    end

    it 'sets custom separator' do
      router = Hanami::Router.new(action_separator: '^')
      route  = router.root(to: 'test^show')

      expect(route.dest).to eq(Test::Show)
    end

    it 'checks if there are defined routes' do
      router = Hanami::Router.new
      expect(defined? router).to be_falsy

      router = Hanami::Router.new { get '/', to: ->(env) { } }
      expect(defined? router).to be_truthy
    end

    it 'recognizes root' do
      expect(@app.get('/', lint: true).status).to eq(200)
    end

    it 'recognizes path' do
      expect(@app.get('/route', lint: true).status).to eq(200)
    end

    it 'recognizes named path' do
      expect(@app.get('/named_route', lint: true).status).to eq(200)
    end

    it 'recognizes resource' do
      expect(@app.get('/avatar', lint: true).status).to eq(200)
    end

    it 'recognizes resources' do
      expect(@app.get('/avatar', lint: true).status).to eq(200)
    end

    it 'recognizes namespaced path' do
      expect(@app.get('/admin/dashboard', lint: true).status).to eq(200)
    end
  end
end
