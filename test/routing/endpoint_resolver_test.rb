require 'test_helper'

describe Lotus::Routing::EndpointResolver do
  before do
    @resolver = Lotus::Routing::EndpointResolver.new
  end

  it 'recognizes :to when it is a callable object' do
    endpoint = Object.new
    endpoint.define_singleton_method(:call) { }

    options = { to: endpoint }

    @resolver.resolve(options).must_equal(endpoint)
  end

  it 'recognizes :to when it is a string that references a class that can be retrieved now' do
    options = { to: 'test_endpoint' }
    @resolver.resolve(options).call({}).must_equal 'Hi from TestEndpoint!'
  end

  describe 'when :to references a missing class' do
    it 'if the class is available when invoking call, it succeed' do
      options  = { to: 'lazy_controller' }
      endpoint = @resolver.resolve(options)
      LazyController = Class.new(Object) { define_method(:call) {|env| env } }

      endpoint.call({}).must_equal({})
    end

    it 'if the class is not available when invoking call, it raises error' do
      options  = { to: 'missing_endpoint' }
      endpoint = @resolver.resolve(options)

      -> { endpoint.call({}) }.must_raise NameError
    end
  end

  it 'recognizes :to when it is a string with separator' do
    options = { to: 'test#show' }
    @resolver.resolve(options).call({}).must_equal 'Hi from Test::Show!'
  end

  describe 'namespace' do
    before do
      @resolver = Lotus::Routing::EndpointResolver.new(TestApp)
    end

    it 'recognizes :to when it is a string and an explicit namespace' do
      options = { to: 'test_endpoint' }
      @resolver.resolve(options).call({}).must_equal 'Hi from TestApp::TestEndpoint!'
    end

    it 'recognizes :to when it is a string with separator and it has an explicit namespace' do
      options = { to: 'test2#show' }
      @resolver.resolve(options).call({}).must_equal 'Hi from TestApp::Test2Controller::Show!'
    end
  end

  describe 'options' do
    it 'recognizes from custom options key' # instead of :to
    it 'matches controller and action with a custom separator' # instead of /#/
    it 'adds custom controller name suffix' # 'Controller::'
  end
end
