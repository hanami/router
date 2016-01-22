require 'test_helper'

describe Hanami::Router do
  before do
    @router = Hanami::Router.new do
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
      @app.request(verb.upcase, '/backend', lint: true).body.must_equal 'home'
    end

    it "accepts #{ verb } for an instance endpoint when a class is given" do
      @app.request(verb.upcase, '/api', lint: true).body.must_equal 'home'
    end

    it "accepts #{ verb } for an instance endpoint" do
      @app.request(verb.upcase, '/api2', lint: true).body.must_equal 'home'
    end

    it "accepts #{ verb } for a proc endpoint" do
      @app.request(verb.upcase, '/proc', lint: true).body.must_equal 'proc'
    end

    it "accepts #{ verb } for a controller endpoint" do
      @app.request(verb.upcase, '/dashboard', lint: true).body.must_equal 'dashboard'
    end

    it "accepts sub paths when #{ verb } is requested" do
      @app.request(verb.upcase, '/api/articles', lint: true).body.must_equal 'articles'
    end

    it "returns 404 when #{ verb } is requested and the app cannot find the resource" do
      @app.request(verb.upcase, '/api/unknown', lint: true).status.must_equal 404
    end
  end
end
