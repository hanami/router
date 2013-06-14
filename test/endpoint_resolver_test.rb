require 'test_helper'

describe Lotus::EndpointResolver do
  before do
    @resolver = Lotus::EndpointResolver.new
  end

  it 'recognizes :to when it is a callable object' do
    endpoint = Object.new
    endpoint.define_singleton_method(:call) { }

    options = { to: endpoint }

    @resolver.resolve(options).must_equal(endpoint)
  end

  it 'recognizes :to when it is a string' do
    options = { to: 'test_endpoint' }
    @resolver.resolve(options).must_be_instance_of(TestEndpoint)
  end

  it 'recognizes :to when it is a string with separator' do
    options = { to: 'test#show' }
    @resolver.resolve(options).must_be_instance_of(TestController::Show)
  end

  describe 'namespace' do
    before do
      @resolver = Lotus::EndpointResolver.new(TestApp)
    end

    it 'recognizes :to when it is a string and an explicit namespace' do
      options = { to: 'test_endpoint' }
      @resolver.resolve(options).must_be_instance_of(TestApp::TestEndpoint)
    end

    it 'recognizes :to when it is a string with separator and it has an explicit namespace' do
      options = { to: 'test2#show' }
      @resolver.resolve(options).must_be_instance_of(TestApp::Test2Controller::Show)
    end
  end

  describe 'options' do
    it 'recognizes from custom options key' # instead of :to
    it 'matches controller and action with a custom separator' # instead of /#/
    it 'adds custom controller name suffix' # 'Controller::'
  end
end
