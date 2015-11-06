require 'test_helper'

describe 'Router wrapper as container' do
  it 'reach correct application' do
    @router_container = Lotus::Router.new(scheme: 'https', host: 'lotus.test', port: 443) do
      mount Front::App, at: '/front'
      mount Back::App, at: '/back'
    end

    @app = Rack::MockRequest.new(@router_container)
    response = @app.get('/front/home', lint: true)
    response.body.must_equal 'front'
    response = @app.get('/back/home', lint: true)
    response.body.must_equal 'back'
  end
end
