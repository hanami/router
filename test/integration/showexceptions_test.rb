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

    it 'shows textual exception stack trace by default' do
      response = @app.get('/', lint: true)

      response.status.must_equal 500
      response.body.must_match 'Lotus::Routing::EndpointNotFound'
    end

    it 'shows exceptions page (when requesting HTML)' do
      response = @app.get('/', 'HTTP_ACCEPT' => 'text/html', lint: true)

      response.status.must_equal 500
      response.body.must_match '<body>'
      response.body.must_match 'Lotus::Routing::EndpointNotFound'
    end
  end
end
