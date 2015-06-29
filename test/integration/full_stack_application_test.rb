require 'test_helper'

describe 'Lotus integration' do
  before do
    @router_container = Lotus::Router.new(scheme: 'https', host: 'lotus.test', port: 443) do
      mount Dashboard::Index, at: '/dashboard'
      mount Backend::App, at: '/backend'
    end

    @routes = Lotus::Router.new(namespace: Travels::Controllers) do
      get '/dashboard',    to: 'journeys#index'
      resources :journeys, only: [:index]
    end

    @app = Rack::MockRequest.new(@routes)
  end

  it 'recognizes single endpoint' do
    response = @app.get('/dashboard')
    response.body.must_equal 'Hello from Travels::Controllers::Journeys::Index'
  end

  it 'recognizes RESTful endpoint' do
    response = @app.get('/journeys')
    response.body.must_equal 'Hello from Travels::Controllers::Journeys::Index'
  end
end
