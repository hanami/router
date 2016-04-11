require 'test_helper'

describe 'Router wrapper as container' do
  it 'reach correct application' do
    @router_container = Hanami::Router.new(scheme: 'https', host: 'hanami.test', port: 443) do
      mount Front::App, at: '/front'
      mount Back::App, at: '/back'
    end

    @app = Rack::MockRequest.new(@router_container)
    response = @app.get('/front/home', lint: true)
    response.body.must_equal 'front'
    response = @app.get('/back/home', lint: true)
    response.body.must_equal 'back'
  end

  it 'matches against host' do
    @router_container = Hanami::Router.new(scheme: 'https', host: 'hanami.test', port: 443) do
      mount Front::App, at: '/front', host: 'www.hanami.test'
      mount Back::App, at: '/front'
    end

    @app = Rack::MockRequest.new(@router_container)
    response = @app.get('https://www.hanami.test/front/home', lint: true)
    response.body.must_equal 'front'
    response = @app.get('/front/home', lint: true)
    response.body.must_equal 'back'
  end
end
