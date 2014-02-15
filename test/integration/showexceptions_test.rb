require 'test_helper'

describe Lotus::Router do
  describe 'usage with Rack::ShowExceptions' do
    before do
      router  = Lotus::Router.new { get '/', to: 'missing#index' }
      builder = Rack::Builder.new
      builder.use Rack::ShowExceptions
      builder.run router

      @app = Rack::MockRequest.new(builder)
    end

    it 'shows exceptions page' do
      response = @app.get('/')

      response.status.must_equal 500
      response.body.must_match '<body>'
      response.body.must_match 'Lotus::Routing::EndpointNotFound'
    end
  end
end
