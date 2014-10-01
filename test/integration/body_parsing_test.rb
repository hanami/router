require 'test_helper'
require 'json'

describe 'Body parsing' do
  before do
    json_endpoint = ->(env) {
      [200, {}, [JSON.generate(env['router.params'])]]
    }

    @routes = Lotus::Router.new(parsers: [:json]) {
      patch '/books/:id', to: json_endpoint
    }

    @app = Rack::MockRequest.new(@routes)
  end

  it 'is successful (JSON)' do
    body     = StringIO.new(JSON.generate({published: 'true'}))
    response = @app.patch('/books/23', 'CONTENT_TYPE' => 'application/json', 'rack.input' => body)

    response.status.must_equal 200
    response.body.must_equal %({"published":"true","id":"23"})
  end
end
