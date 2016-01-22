require 'test_helper'

describe Hanami::Router do
  before do
    @router = Hanami::Router.new { get '/', to: ->(env) {} }
    @app    = Rack::MockRequest.new(@router)
  end

  it 'returns 404 for unknown path' do
    @app.get('/unknown', lint: true).status.must_equal 404
  end

  it 'returns 405 for unacceptable HTTP method' do
    @app.post('/', lint: true).status.must_equal 405
  end
end
