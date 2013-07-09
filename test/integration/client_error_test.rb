require 'test_helper'

describe Lotus::Router do
  before do
    @router = Lotus::Router.draw { get '/', to: ->(env) {} }
    @app    = Rack::MockRequest.new(@router)
  end

  it 'returns 404 for unknown path' do
    @app.get('/unknown').status.must_equal 404
  end

  it 'returns 405 for unacceptable HTTP method' do
    @app.post('/').status.must_equal 405
  end
end
