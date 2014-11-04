require 'test_helper'

describe 'Body parsing' do
  before do
    endpoint = ->(env) {
      [200, {}, [env['router.params']]]
    }

    @routes = Lotus::Router.new(parsers: [:json, XmlParser.new]) {
      patch '/books/:id',   to: endpoint
      patch '/authors/:id', to: endpoint
    }

    @app = Rack::MockRequest.new(@routes)
  end

  it 'is successful (JSON)' do
    body     = StringIO.new( %({"published":"true"}) )
    response = @app.patch('/books/23', 'CONTENT_TYPE' => 'application/json', 'rack.input' => body)

    response.status.must_equal 200
    response.body.must_equal %({"published"=>"true", :id=>"23"})
  end

  it 'is idempotent' do
    2.times do
      body     = StringIO.new( %({"published":"true"}) )
      response = @app.patch('/books/23', 'CONTENT_TYPE' => 'application/json', 'rack.input' => body)

      response.status.must_equal 200
      response.body.must_equal %({"published"=>"true", :id=>"23"})
    end
  end

  it 'is successful (XML)' do
    body     = StringIO.new( %(<name>LG</name>) )
    response = @app.patch('/authors/23', 'CONTENT_TYPE' => 'application/xml', 'rack.input' => body)

    response.status.must_equal 200
    response.body.must_equal %({"name"=>"LG", :id=>"23"})
  end

  it 'is successful (XML aliased mime)' do
    body     = StringIO.new( %(<name>MGF</name>) )
    response = @app.patch('/authors/15', 'CONTENT_TYPE' => 'text/xml', 'rack.input' => body)

    response.status.must_equal 200
    response.body.must_equal %({"name"=>"MGF", :id=>"15"})
  end
end
