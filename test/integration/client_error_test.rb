require 'test_helper'

describe Lotus::Router do
  before do
    @router = Lotus::Router.new do
      get '/', to: ->(env) {}
      get '/dashboard', to: 'this#does_not_exist'
      get '/some_exception', to: ->(env) { raise StandardError('Hello') }
    end
    @app    = Rack::MockRequest.new(@router)
  end

  it 'returns 404 for unknown path' do
    @app.get('/unknown').status.must_equal 404
  end

  it 'returns 405 for unacceptable HTTP method' do
    @app.post('/').status.must_equal 405
  end

  it 'returns 500 if the endpoint is not found' do
    @app.post('/dashboard').status.must_equal 500
  end

  it 'returns 500 if the endpoint raises an exception' do
    @app.post('/some_exception').status.must_equal 500
  end
end
