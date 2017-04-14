require 'test_helper'

describe "404 405" do
  before do
    @router = Hanami::Router.new
    @app    = Rack::MockRequest.new(@router)
  end

  after do
    @router.reset!
  end

  describe '#resources' do
    before do
      @router.resources 'flowers'
    end

    it "should return the right http errors for /flowers" do
      @app.request('GET', '/flowers', lint: true).status.must_equal 200
      @app.request('POST', '/flowers', lint: true).status.must_equal 200
      @app.request('PATCH', '/flowers', lint: true).status.must_equal 405
      @app.request('PUT', '/flowers', lint: true).status.must_equal 405
      @app.request('DELETE', '/flowers', lint: true).status.must_equal 405
    end

    it "should return the right http errors for /flowers/new" do
      @app.request('GET', '/flowers/new', lint: true).status.must_equal 200
      @app.request('POST', '/flowers/new', lint: true).status.must_equal 405
      @app.request('PATCH', '/flowers/new', lint: true).status.must_equal 405
      @app.request('PUT', '/flowers/new', lint: true).status.must_equal 405
      @app.request('DELETE', '/flowers/new', lint: true).status.must_equal 405
    end

    it "should return the right http errors for /flowers/:id" do
      @app.request('GET', '/flowers/1', lint: true).status.must_equal 200
      @app.request('POST', '/flowers/1', lint: true).status.must_equal 405
      @app.request('PATCH', '/flowers/1', lint: true).status.must_equal 200
      @app.request('PUT', '/flowers/1', lint: true).status.must_equal 200
      @app.request('DELETE', '/flowers/1', lint: true).status.must_equal 200
    end

    it "should return the right http errors for /flowers/:id/edit" do
      @app.request('GET', '/flowers/1/edit', lint: true).status.must_equal 200
      @app.request('POST', '/flowers/1/edit', lint: true).status.must_equal 405
      @app.request('PATCH', '/flowers/1/edit', lint: true).status.must_equal 405
      @app.request('PUT', '/flowers/1/edit', lint: true).status.must_equal 405
      @app.request('DELETE', '/flowers/1/edit', lint: true).status.must_equal 405
    end
  end

  describe '#resource' do
    before do
      @router.resource 'user'
    end

    it "should return the right http errors for /user" do
      @app.request('GET', '/user', lint: true).status.must_equal 200
      @app.request('POST', '/user', lint: true).status.must_equal 200
      @app.request('PATCH', '/user', lint: true).status.must_equal 200
      @app.request('PUT', '/user', lint: true).status.must_equal 405
      @app.request('DELETE', '/user', lint: true).status.must_equal 200
    end

    it "should return the right http errors for /user/new" do
      @app.request('GET', '/user/new', lint: true).status.must_equal 200
      @app.request('POST', '/user/new', lint: true).status.must_equal 405
      @app.request('PATCH', '/user/new', lint: true).status.must_equal 405
      @app.request('PUT', '/user/new', lint: true).status.must_equal 405
      @app.request('DELETE', '/user/new', lint: true).status.must_equal 405
    end

    it "should return the right http errors for /user/edit" do
      @app.request('GET', '/user/edit', lint: true).status.must_equal 200
      @app.request('POST', '/user/edit', lint: true).status.must_equal 405
      @app.request('PATCH', '/user/edit', lint: true).status.must_equal 405
      @app.request('PUT', '/user/edit', lint: true).status.must_equal 405
      @app.request('DELETE', '/user/edit', lint: true).status.must_equal 405
    end
  end

  describe "#get" do
    before do
      @router.get('/flowers/1', to: ->(env) { [200, {}, ["get"]] })
    end

    it "should return the right http errors" do
      @app.request('GET', '/flowers/1', lint: true).status.must_equal 200
      @app.request('POST', '/flowers/1', lint: true).status.must_equal 405
      @app.request('PATCH', '/flowers/1', lint: true).status.must_equal 405
      @app.request('PUT', '/flowers/1', lint: true).status.must_equal 405
      @app.request('DELETE', '/flowers/1', lint: true).status.must_equal 405
    end
  end

  describe "#post" do
    before do
      @router.post('/flowers', to: ->(env) { [200, {}, ["post"]] })
    end

    it "should return the right http errors" do
      @app.request('GET', '/flowers', lint: true).status.must_equal 405
      @app.request('POST', '/flowers', lint: true).status.must_equal 200
      @app.request('PATCH', '/flowers', lint: true).status.must_equal 405
      @app.request('PUT', '/flowers', lint: true).status.must_equal 405
      @app.request('DELETE', '/flowers', lint: true).status.must_equal 405
    end
  end

  describe "#patch" do
    before do
      @router.patch('/flowers/1', to: ->(env) { [200, {}, ["patch"]] })
    end

    it "should return the right http errors" do
      @app.request('GET', '/flowers/1', lint: true).status.must_equal 405
      @app.request('POST', '/flowers/1', lint: true).status.must_equal 405
      @app.request('PATCH', '/flowers/1', lint: true).status.must_equal 200
      @app.request('PUT', '/flowers/1', lint: true).status.must_equal 405
      @app.request('DELETE', '/flowers/1', lint: true).status.must_equal 405
    end
  end

  describe "#put" do
    before do
      @router.put('/flowers/1', to: ->(env) { [200, {}, ["put"]] })
    end

    it "should return the right http errors" do
      @app.request('GET', '/flowers/1', lint: true).status.must_equal 405
      @app.request('POST', '/flowers/1', lint: true).status.must_equal 405
      @app.request('PATCH', '/flowers/1', lint: true).status.must_equal 405
      @app.request('PUT', '/flowers/1', lint: true).status.must_equal 200
      @app.request('DELETE', '/flowers/1', lint: true).status.must_equal 405
    end
  end

  describe "#delete" do
    before do
      @router.delete('/flowers/1', to: ->(env) { [200, {}, ["destroy"]] })
    end

    it "should return the right http errors" do
      @app.request('GET', '/flowers/1', lint: true).status.must_equal 405
      @app.request('POST', '/flowers/1', lint: true).status.must_equal 405
      @app.request('PATCH', '/flowers/1', lint: true).status.must_equal 405
      @app.request('PUT', '/flowers/1', lint: true).status.must_equal 405
      @app.request('DELETE', '/flowers/1', lint: true).status.must_equal 200
    end
  end
end
