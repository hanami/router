RSpec.describe Hanami::Router do
  before do
    @original_stderr = $stderr
    $stderr = File.open(File::NULL, "w")
  end

  after do
    $stderr = @original_stderr
    @original_stderr = nil
  end

  # Bug https://github.com/hanami/router/issues/73
  it 'respects the Rack spec' do
    router = Hanami::Router.new(force_ssl: true)
    router.public_send(:get, '/http_destination', to: ->(_env) { [200, {}, ['http destination!']] })
    app = Rack::MockRequest.new(router)

    app.get('/http_destination', lint: true)
  end

  context "force_ssl deprecation" do
    it 'display a message when force_ssl is true' do
      expect { Hanami::Router.new(force_ssl: true) }.to output(/force_ssl option is deprecated, please delegate this behaviour to Nginx\/Apache or use a Rack middleware like `rack-ssl`/).to_stderr
    end

    it "don't display a message when force_ssl is false" do
      expect { Hanami::Router.new(force_ssl: false) }.to_not output(/force_ssl option is deprecated, please delegate this behaviour to Nginx\/Apache or use a Rack middleware like `rack-ssl`/).to_stderr
    end
  end

  %w[get].each do |verb|
    it "force_ssl to true and scheme is http, return 307 and new location, verb: #{verb}" do
      router = Hanami::Router.new(force_ssl: true)
      router.public_send(verb, '/http_destination', to: ->(_env) { [200, {}, ['http destination!']] })
      app = Rack::MockRequest.new(router)

      status, headers, body = app.public_send(verb, '/http_destination', lint: true).to_a

      expect(status).to eq(301)
      expect(headers['Location']).to eq('https://localhost:443/http_destination')
      expect(body).to eq([])
    end

    it "force_ssl to true and scheme is https, return 200, verb: #{verb}" do
      router = Hanami::Router.new(force_ssl: true, scheme: 'https', host: 'hanami.test')
      router.public_send(verb, '/http_destination', to: ->(_env) { [200, {}, ['http destination!']] })
      app = Rack::MockRequest.new(router)

      status, headers, body = app.public_send(verb, 'https://hanami.test/http_destination', lint: true).to_a

      expect(status).to eq(200)
      expect(headers['Location']).to be_nil
      expect(body).to eq(['http destination!'])
    end
  end

  %w[post put patch delete options].each do |verb|
    it "force_ssl to true and scheme is http, return 307 and new location, verb: #{verb}" do
      router = Hanami::Router.new(force_ssl: true)
      router.public_send(verb, '/http_destination', to: ->(_env) { [200, {}, ['http destination!']] })
      app = Rack::MockRequest.new(router)

      status, headers, body = app.public_send(verb, '/http_destination', lint: true).to_a

      expect(status).to eq(307)
      expect(headers['Location']).to eq('https://localhost:443/http_destination')
      expect(body).to eq([])
    end

    it "force_ssl to true and added query string, verb: #{verb}" do
      router = Hanami::Router.new(force_ssl: true)
      router.public_send(verb, '/http_destination', to: ->(_env) { [200, {}, ['http destination!']] })

      app = Rack::MockRequest.new(router)

      status, headers, body = app.public_send(verb, '/http_destination?foo=bar', lint: true).to_a

      expect(status).to eq(307)
      expect(headers['Location']).to eq('https://localhost:443/http_destination?foo=bar')
      expect(body).to eq([])
    end

    it "force_ssl to true and added port, verb: #{verb}" do
      router = Hanami::Router.new(force_ssl: true, port: 4000)
      router.public_send(verb, '/http_destination', to: ->(_env) { [200, {}, ['http destination!']] })

      app = Rack::MockRequest.new(router)

      status, headers, body = app.public_send(verb, '/http_destination?foo=bar', lint: true).to_a

      expect(status).to eq(307)
      expect(headers['Location']).to eq('https://localhost:4000/http_destination?foo=bar')
      expect(body).to eq([])
    end

    it "force_ssl to true, added host and port, verb: #{verb}" do
      router = Hanami::Router.new(force_ssl: true, host: 'hanamirb.org', port: 4000)
      router.public_send(verb, '/http_destination', to: ->(_env) { [200, {}, ['http destination!']] })

      app = Rack::MockRequest.new(router)

      status, headers, body = app.public_send(verb, '/http_destination?foo=bar', lint: true).to_a

      expect(status).to eq(307)
      expect(headers['Location']).to eq('https://hanamirb.org:4000/http_destination?foo=bar')
      expect(body).to eq([])
    end

    it "force_ssl to false and scheme is http, return 200 and doesn't return new location, verb: #{verb}" do
      router = Hanami::Router.new(force_ssl: false)
      router.public_send(verb, '/http_destination', to: ->(_env) { [200, {}, ['http destination!']] })

      app = Rack::MockRequest.new(router)

      status, headers, body = app.public_send(verb, '/http_destination', lint: true).to_a

      expect(status).to eq(200)
      expect(headers['Location']).to be_nil
      expect(body).to eq(['http destination!'])
    end

    it "force_ssl to false and scheme is https, return 200 and doesn't return new location, verb: #{verb}" do
      router = Hanami::Router.new(force_ssl: false, scheme: 'https')
      router.public_send(verb, '/http_destination', to: ->(_env) { [200, {}, ['http destination!']] })

      app = Rack::MockRequest.new(router)

      status, headers, body = app.public_send(verb, '/http_destination', lint: true).to_a

      expect(status).to eq(200)
      expect(headers['Location']).to be_nil
      expect(body).to eq(['http destination!'])
    end
  end
end
