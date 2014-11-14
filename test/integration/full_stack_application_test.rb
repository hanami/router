require 'test_helper'

describe 'Lotus integration' do
  before do
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
