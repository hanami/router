require 'test_helper'

describe 'Pass on response' do
  before do
    @routes = Lotus::Router.draw { get '/', to: ->(env) { Rack::Response.new } }
    @app    = Rack::MockRequest.new(@routes)
  end

  it 'is successful' do
    response = @app.get('/')
    response.status.must_equal 200
  end
end
