require 'test_helper'

describe Lotus::Router do
  before do
    @router = Lotus::Router.new do
      mount Api::App,                      at: '/api'
      mount Api::App.new,                  at: '/api2'
      mount Backend::App,                  at: '/backend'
      mount ->(env) {[200, {}, ['proc']]}, at: '/proc'
      mount 'dashboard#index',             at: '/dashboard'
    end

    @app = Rack::MockRequest.new(@router)
  end

  [ 'get', 'post', 'delete', 'put', 'patch', 'trace', 'options' ].each do |verb|
    it "accepts #{ verb } for a class endpoint" do
      @app.request(verb.upcase, '/backend').body.must_equal 'home'
    end

    it "accepts #{ verb } for an instance endpoint when a class is given" do
      @app.request(verb.upcase, '/api').body.must_equal 'home'
    end

    it "accepts #{ verb } for an instance endpoint" do
      @app.request(verb.upcase, '/api2').body.must_equal 'home'
    end

    it "accepts #{ verb } for a proc endpoint" do
      @app.request(verb.upcase, '/proc').body.must_equal 'proc'
    end

    it "accepts #{ verb } for a controller endpoint" do
      @app.request(verb.upcase, '/dashboard').body.must_equal 'dashboard'
    end

    it "accepts sub paths when #{ verb } is requested" do
      @app.request(verb.upcase, '/api/articles').body.must_equal 'articles'
    end

    it "returns 404 when #{ verb } is requested and the app cannot find the resource" do
      @app.request(verb.upcase, '/api/unknown').status.must_equal 404
    end
  end
end
