require 'test_helper'
require 'rack/test'

describe 'SCRIPT_NAME' do
  include Rack::Test::Methods

  before do
    @container = Hanami::Router.new do
      @some_test_router = Hanami::Router.new(prefix: '/admin') {
        get '/foo', to: ->(env) { [200, {}, [::Rack::Request.new(env).url]] }, as: :foo
      }
      mount @some_test_router, at: '/admin'
    end
  end

  def app
    @container
  end

  def response
    last_response
  end

  def request
    last_request
  end

  it 'generates proper path' do
    router = @container.instance_variable_get(:@some_test_router)
    router.path(:foo).must_equal '/admin/foo'
  end

  it 'generates proper url' do
    router = @container.instance_variable_get(:@some_test_router)
    router.url(:foo).must_equal 'http://localhost/admin/foo'
  end

  it 'is successfuly parsing a JSON body' do
    script_name = '/admin/foo'
    get script_name

    response.status.must_equal 200
    request.env['SCRIPT_NAME'].must_equal script_name
    request.env['PATH_INFO'].must_equal ''
    response.body.must_equal "http://example.org#{ script_name }"
  end
end
