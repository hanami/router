RSpec.describe Hanami::Routing::EndpointResolver do
  before do
    @resolver = Hanami::Routing::EndpointResolver.new
  end

  it 'recognizes :to when it is a callable object' do
    endpoint = Object.new
    endpoint.define_singleton_method(:call) { }

    options = { to: endpoint }

    expect(@resolver.resolve(options)).to eq(endpoint)
  end

  it 'recognizes :to when it is a string that references a class that can be retrieved now' do
    options = { to: 'test_endpoint' }
    expect(@resolver.resolve(options).call({})).to eq( 'Hi from TestEndpoint!')
  end

  describe 'when :to references a missing class' do
    it 'if the class is available when invoking call, it succeed' do
      options  = { to: 'lazy_controller' }
      endpoint = @resolver.resolve(options)
      LazyController = Class.new(Object) { define_method(:call) {|env| env } }

      expect(endpoint.call({})).to eq({})
    end

    it 'if the class is not available when invoking call, it raises error' do
      options  = { to: 'missing_endpoint' }
      endpoint = @resolver.resolve(options)

      expect { endpoint.call({})}.to raise_error(Hanami::Routing::EndpointNotFound)
    end
  end

  it 'recognizes :to when it is a string with separator' do
    options = { to: 'test#show' }
    expect(@resolver.resolve(options).call({})).to eq( 'Hi from Test::Show!')
  end

  it 'returns the default endpoint when cannot match anything' do
    options = { to: 23 }
    expect(@resolver.resolve(options).call({}).first).to eq( 404)
  end

  describe 'namespace' do
    before do
      @resolver = Hanami::Routing::EndpointResolver.new(namespace: TestApp)
    end

    it 'recognizes :to when it is a string and an explicit namespace' do
      options = { to: 'test_endpoint' }
      expect(@resolver.resolve(options).call({})).to eq( 'Hi from TestApp::TestEndpoint!')
    end

    it 'recognizes :to when it is a string with separator and it has an explicit namespace' do
      options = { to: 'test2#show' }
      expect(@resolver.resolve(options).call({})).to eq( 'Hi from TestApp::Test2::Show!')
    end

    it 'recognizes :to when it is dasherized' do
      options = { to: 'test-endpoint' }
      expect(@resolver.resolve(options).call({})).to eq( 'Hi from TestApp::TestEndpoint!')
    end
  end

  describe 'endpoint' do
    before do
      @resolver = Hanami::Routing::EndpointResolver.new(namespace: Web::Controllers)
    end

    it 'if :to is an action without middleware' do
      options = { to: 'dashboard#index' }
      expect(@resolver.resolve(options).class).to eq( Hanami::Routing::ClassEndpoint)
    end

    it 'if :to is an action with middleware' do
      options = { to: 'home#index' }
      expect(@resolver.resolve(options).class).to eq( Hanami::Routing::Endpoint)
    end
  end

  describe 'endpoint with nested routes' do
    before :all do
      class NestedRoutesApp
        def call(env)
        end

        def routes
          Hanami::Router.new do
            get '/home', to: 'home#index'
          end
        end
      end
    end

    it 'responds to :routes' do
      expect(@resolver.resolve(to: NestedRoutesApp).respond_to?(:routes)).to eq( true)
    end

    after do
      Object.send(:remove_const, :NestedRoutesApp)
    end
  end

  describe 'custom endpoint' do
    before :all do
      class CustomEndpoint
        def initialize(endpoint)
          @endpoint = endpoint
        end
      end

      @resolver = Hanami::Routing::EndpointResolver.new(endpoint: CustomEndpoint)
    end

    after do
      Object.send(:remove_const, :CustomEndpoint)
    end

    it 'returns specified endpoint instance' do
      expect(@resolver.resolve({}).class).to eq(Hanami::Routing::Endpoint)
    end
  end

  describe 'custom separator' do
    before do
      @resolver = Hanami::Routing::EndpointResolver.new(action_separator: action_separator)
    end

    let(:action_separator) { '@' }

    it 'matches controller and action with a custom separator' do
      options = { to: "test#{ action_separator }show" }
      expect(@resolver.resolve(options).call({})).to eq( 'Hi from Test::Show!')
    end
  end

  describe 'custom suffix' do
    before do
      @resolver = Hanami::Routing::EndpointResolver.new(suffix: suffix)
    end

    let(:suffix) { 'Controller::' }

    it 'matches controller and action with a custom separator' do
      options = { to: 'test#show' }
      expect(@resolver.resolve(options).call({})).to eq( 'Hi from Test::Show!')
    end
  end

  describe 'custom pattern' do
    before do
      @resolver = Hanami::Routing::EndpointResolver.new(pattern: pattern)
    end

    let(:pattern) { 'Controllers::%{controller}::%{action}' }

    it 'matches controller and action with a custom pattern' do
      options = { to: 'test#show' }
      expect(@resolver.resolve(options).call({})).to eq( 'Hi from Controllers::Test::Show!')
    end
  end
end
