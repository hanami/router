require 'hanami/middleware/body_parser'

RSpec.describe 'Body parsing' do
  before do
    endpoint = lambda { |env|
      [200, {}, [env['router.params'].inspect]]
    }
    not_parsed_endpoint = lambda { |env|
      [200, {}, ['Hello']]
    }

    @routes = Hanami::Router.new do
      patch '/books/:id',   to: endpoint
      patch '/authors/:id', to: endpoint
      get   '/books',       to: not_parsed_endpoint
    end

    middleware = Hanami::Middleware::BodyParser.new(@routes, [:json, XmlMiddelwareParser])
    @app = Rack::MockRequest.new(middleware)
  end

  context 'Not POST, PUT, PATCH request' do
    it 'is successful' do
      response = @app.get('/books', 'CONTENT_TYPE' => 'text/plain', lint: true)

      expect(response.status).to eq(200)
      expect(response.body).to eq('Hello')
    end
  end

  context 'JSON' do
    it 'is successful (JSON)' do
      body     = StringIO.new(%({"published":"true"}).encode(Encoding::ASCII_8BIT))
      response = @app.patch('/books/23', 'CONTENT_TYPE' => 'application/json', 'rack.input' => body, lint: true)

      expect(response.status).to eq(200)
      expect(response.body).to eq(%({:published=>"true", :id=>"23"}))
    end

    # See https://github.com/hanami/router/issues/124
    it 'does not overrides URI params' do
      body     = StringIO.new(%({"id":"1"}).encode(Encoding::ASCII_8BIT))
      response = @app.patch('/books/23', 'CONTENT_TYPE' => 'application/json', 'rack.input' => body, lint: true)

      expect(response.status).to eq(200)
      expect(response.body).to eq(%({:id=>"23"}))
    end

    it 'is successful (JSON as array)' do
      body     = StringIO.new(%(["alpha", "beta"]).encode(Encoding::ASCII_8BIT))
      response = @app.patch('/books/23', 'CONTENT_TYPE' => 'application/json', 'rack.input' => body, lint: true)

      expect(response.status).to eq(200)
      expect(response.body).to eq(%({"_"=>["alpha", "beta"], :id=>"23"}))
    end

    # See https://github.com/hanami/utils/issues/169
    it 'does not eval untrusted input' do
      body     = StringIO.new(%({"json_class": "Foo"}).encode(Encoding::ASCII_8BIT))
      response = @app.patch('/books/23', 'CONTENT_TYPE' => 'application/json', 'rack.input' => body, lint: true)

      expect(response.status).to eq(200)
      expect(response.body).to eq(%({:json_class=>"Foo", :id=>"23"}))
    end

    it 'is idempotent' do
      2.times do
        body     = StringIO.new(%({"published":"true"}).encode(Encoding::ASCII_8BIT))
        response = @app.patch('/books/23', 'CONTENT_TYPE' => 'application/json', 'rack.input' => body, lint: true)

        expect(response.status).to eq(200)
        expect(response.body).to eq(%({:published=>"true", :id=>"23"}))
      end
    end
  end

  context 'XML' do
    it 'is successful (XML)' do
      body     = StringIO.new(%(<name>LG</name>).encode(Encoding::ASCII_8BIT))
      response = @app.patch('/authors/23', 'CONTENT_TYPE' => 'application/xml', 'rack.input' => body, lint: true)

      expect(response.status).to eq(200)
      expect(response.body).to eq(%({:name=>"LG", :id=>"23"}))
    end

    it 'is successful (XML aliased mime)' do
      body     = StringIO.new(%(<name>MGF</name>).encode(Encoding::ASCII_8BIT))
      response = @app.patch('/authors/15', 'CONTENT_TYPE' => 'text/xml', 'rack.input' => body, lint: true)

      expect(response.status).to eq(200)
      expect(response.body).to eq(%({:name=>"MGF", :id=>"15"}))
    end
  end
end
