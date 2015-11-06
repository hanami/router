require 'test_helper'

describe Lotus::Router do
  it 'respects the Rack spec' do
    router = Lotus::Router.new(force_ssl: true)
    router.public_send(:get, '/http_destination', to: ->(env) { [200, {}, ['http destination!']] })
    app = Rack::MockRequest.new(router)

    app.get('/http_destination', lint: true)
  end

  %w{get}.each do |verb|
    it "force_ssl to true and scheme is http, return 307 and new location, verb: #{verb}" do
      router = Lotus::Router.new(force_ssl: true)
      router.public_send(verb, '/http_destination', to: ->(env) { [200, {}, ['http destination!']] })
      app = Rack::MockRequest.new(router)

      status, headers, body = app.public_send(verb, '/http_destination')

      status.must_equal 301
      headers['Location'].must_equal 'https://localhost:443/http_destination'
      body.body.must_equal ''
    end

    it "force_ssl to true and scheme is https, return 200, verb: #{verb}" do
      router = Lotus::Router.new(force_ssl: true, scheme: 'https', host: 'lotus.test')
      router.public_send(verb, '/http_destination', to: ->(env) { [200, {}, ['http destination!']] })
      app = Rack::MockRequest.new(router)

      status, headers, body = app.public_send(verb, 'https://lotus.test/http_destination')

      status.must_equal 200
      headers['Location'].must_be_nil
      body.body.must_equal 'http destination!'
    end
  end

  %w{post put patch delete options}.each do |verb|
    it "force_ssl to true and scheme is http, return 307 and new location, verb: #{verb}" do
      router = Lotus::Router.new(force_ssl: true)
      router.public_send(verb, '/http_destination', to: ->(env) { [200, {}, ['http destination!']] })
      app = Rack::MockRequest.new(router)

      status, headers, body = app.public_send(verb, '/http_destination')

      status.must_equal 307
      headers['Location'].must_equal 'https://localhost:443/http_destination'
      body.body.must_equal ''
    end

    it "force_ssl to true and added query string, verb: #{verb}" do
      router = Lotus::Router.new(force_ssl: true)
      router.public_send(verb, '/http_destination', to: ->(env) { [200, {}, ['http destination!']] })

      app = Rack::MockRequest.new(router)

      status, headers, body = app.public_send(verb, '/http_destination?foo=bar')

      status.must_equal 307
      headers['Location'].must_equal 'https://localhost:443/http_destination?foo=bar'
      body.body.must_equal ''
    end

    it "force_ssl to true and added port, verb: #{verb}" do
      router = Lotus::Router.new(force_ssl: true, port: 4000)
      router.public_send(verb, '/http_destination', to: ->(env) { [200, {}, ['http destination!']] })

      app = Rack::MockRequest.new(router)

      status, headers, body = app.public_send(verb, '/http_destination?foo=bar')

      status.must_equal 307
      headers['Location'].must_equal 'https://localhost:4000/http_destination?foo=bar'
      body.body.must_equal ''
    end

    it "force_ssl to true, added host and port, verb: #{verb}" do
      router = Lotus::Router.new(force_ssl: true, host: 'lotusrb.org', port: 4000)
      router.public_send(verb, '/http_destination', to: ->(env) { [200, {}, ['http destination!']] })

      app = Rack::MockRequest.new(router)

      status, headers, body = app.public_send(verb, '/http_destination?foo=bar')

      status.must_equal 307
      headers['Location'].must_equal 'https://lotusrb.org:4000/http_destination?foo=bar'
      body.body.must_equal ''
    end

    it "force_ssl to false and scheme is http, return 200 and doesn't return new location, verb: #{verb}" do
      router = Lotus::Router.new(force_ssl: false)
      router.public_send(verb, '/http_destination', to: ->(env) { [200, {}, ['http destination!']] })

      app = Rack::MockRequest.new(router)

      status, headers, body = app.public_send(verb, '/http_destination')

      status.must_equal 200
      headers['Location'].must_be_nil
      body.body.must_equal 'http destination!'
    end

    it "force_ssl to false and scheme is https, return 200 and doesn't return new location, verb: #{verb}" do
      router = Lotus::Router.new(force_ssl: false, scheme: 'https')
      router.public_send(verb, '/http_destination', to: ->(env) { [200, {}, ['http destination!']] })

      app = Rack::MockRequest.new(router)

      status, headers, body = app.public_send(verb, '/http_destination')

      status.must_equal 200
      headers['Location'].must_be_nil
      body.body.must_equal 'http destination!'
    end
  end
end
