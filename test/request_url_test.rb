require 'test_helper'
require 'rack/test'

describe 'SCRIPT_NAME' do
  include Rack::Test::Methods

  before do
    @container = Hanami::Router.new do
      mount Hanami::Router.new(prefix: '/admin') {
        get '/foo', to: ->(env) { [200, {}, [::Rack::Request.new(env).url]] }
      }, at: '/admin'
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

  it 'is successfuly parsing a JSON body' do
    script_name = '/admin/foo'
    get script_name

    request.env['SCRIPT_NAME'].must_equal script_name
    response.body.must_equal "http://example.org#{ script_name }"
  end
end
