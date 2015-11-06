require 'test_helper'

describe 'Lotus middleware integration' do
  before do
    @routes = Lotus::Router.new(namespace: Web::Controllers) do
      get '/',          to: 'home#index'
      get '/dashboard', to: 'dashboard#index'
    end

    @app = Rack::MockRequest.new(@routes)
  end

  it 'action with middleware' do
    response = @app.get('/', lint: true)
    response.body.must_equal 'Hello from Web::Controllers::Home::Index'
    response.status.must_equal 200
    response.headers.fetch('X-Middleware').must_equal 'CALLED'
  end

  it 'action without middleware' do
    response = @app.get('/dashboard', lint: true)
    response.body.must_equal 'Hello from Web::Controllers::Dashboard::Index'
    response.status.must_equal 200
    response.headers['X-Middleware'].must_be_nil
  end
end
